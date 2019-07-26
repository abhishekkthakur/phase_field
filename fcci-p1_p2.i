[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 200
  ny = 1
  nz = 0
  xmin = -10
  xmax = 10
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 0
[]

# Defining an AuxVariables for free energy calculation
[AuxVariables]
  [./Fglobal]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

# Defining different parameters
[Variables]
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]

  [./c]
    order = FIRST
    family = LAGRANGE
  [../]

  [./w]
    order = FIRST
    family = LAGRANGE
  [../]

  [./xnd]
    order = FIRST
    family = LAGRANGE
  [../]

  [./xas]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  [./eta]
    variable = eta
    type = FunctionIC
    #type = RandomIC
    #min = 0.4
    #max = 0.6
    function = ic_func_eta
  [../]
  [./c]
    variable = c
    type = FunctionIC
    #type = RandomIC
    #min = 0.4
    #max = 0.6
    function = ic_func_c
  [../]
[]

# Defining the equilibrium phase field profile as described in the KKS model.
[Functions]
  [./ic_func_eta]
    type = ParsedFunction
    #value = x/20
    value = (tanh(x)+1)/2
  [../]

  [./ic_func_c]
    type = ParsedFunction
    #value = x/20
    value = (tanh(x*5)+1)/2
    #value = 0.9*(0.5*(1.0-tanh(x/sqrt(2.0))))^3*(6*(0.5*(1.0-tanh(x/sqrt(2.0))))^2-15*(0.5*(1.0-tanh(x/sqrt(2.0))))+10)+0.1*(1-(0.5*(1.0-tanh(x/sqrt(2.0))))^3*(6*(0.5*(1.0-tanh(x/sqrt(2.0))))^2-15*(0.5*(1.0-tanh(x/sqrt(2.0))))+10))
  [../]
[]

[Materials]
  [./fl]
    type = DerivativeParsedMaterial
    f_name = fl
    args = 'xnd xas'
    # Gibbs free energy expression for phase 1
    function = '(1-xnd-xas)*-57515.479353 + xnd*5000 + xas*5000 + 3*xas*xas*-1.44 + 3*xnd*xnd*2.60 + 3*xnd*xas*-3.225
                + 8.314*300*((1-xnd-xas)*log(1-xnd-xas) + xnd*log(xnd) + xas*log(xas))
                + (1-xnd-xas)*xnd*4.17 + (1-xnd-xas)*xas*-1.04 + xnd*xas*-3.225'
  [../]

  [./fs]
    type = DerivativeParsedMaterial
    f_name = fs
    args = 'xnd xas'
    # Gibbs free energy expression for phase 2
    function = '-12.572 + 7*((xnd-0.5)*(xnd-0.5) + (xas-0.5)*(xas-0.5))
                + 0.5*8.314*300*(2*(1-xnd-xas)*log(2*(1-xnd-xas)) + (1-2*(1-xnd-xas))*log(1-2*(1-xnd-xas)))
                + ((1-xnd-xas)*xnd)*0.51 + (xnd*xas)*16.65 + ((1-xnd-xas)*xas)*6.76'
  [../]

  [./h_eta]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = eta
  [../]

  [./g_eta]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta
  [../]

  [./constants]
    type = GenericConstantMaterial
    prop_names  = 'M   L   eps_sq'
    prop_values = '0.7 0.7 0.0175  '    # eps_sq is the gradient energy coefficient.
  [../]
[]

[Kernels]
  [./PhaseConc]
    type = KKSPhaseConcentration
    ca       = xnd
    variable = xas
    c        = c
    eta      = eta
  [../]

  [./ChemPotSolute]
    type = KKSPhaseChemicalPotential
    variable = xnd
    cb       = xas
    fa_name  = fl
    fb_name  = fs
  [../]

  [./CHBulk]
    type = KKSSplitCHCRes
    variable = c
    ca       = xnd
    cb       = xas
    fa_name  = fl
    fb_name  = fs
    w        = w
  [../]

  [./dcdt]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]

  [./ckernel]
    type = SplitCHWRes
    mob_name = M
    variable = w
  [../]

  [./ACBulkF]
    type = KKSACBulkF
    variable = eta
    fa_name  = fl
    fb_name  = fs
    w       = 0.7           # DW height parameter
    args = 'xnd xas'
  [../]

  [./ACBulkC]
    type = KKSACBulkC
    variable = eta
    ca       = xnd
    cb       = xas
    fa_name  = fl
    fb_name  = fs
  [../]

  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = eps_sq
  [../]

  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]
[]

[AuxKernels]
  [./GlobalFreeEnergy]
    variable = Fglobal
    type = KKSGlobalFreeEnergy
    fa_name = fl
    fb_name = fs
    w = 0.7                   # DW height parameter
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      ilu          nonzero'

  l_max_its = 100
  nl_max_its = 100
  nl_abs_tol = 1e-11

  end_time = 1e7
  #dt = 1
  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    iteration_window = 2
    dt = 100.0
  [../]
  [./Predictor]
    type = SimplePredictor
    scale = 0.5
  [../]
[]

#
# Precondition using handcoded off-diagonal terms
#
[Preconditioning]
  [./full]
    type = SMP
    full = true
  [../]
[]

[Postprocessors]
  [./dofs]
    type = NumDOFs
  [../]

  [./F_tot]
      type = ElementIntegralVariablePostprocessor
      variable = Fglobal
  [../]

  [./C]
      type = ElementAverageValue
      variable = c
  [../]
#  [./integral]
#    type = ElementL2Error
#    variable = eta
#    function = ic_func_eta
#  [../]
[]

[Outputs]
  exodus = true
  console = true
  gnuplot = true
[]
