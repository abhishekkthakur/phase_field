# This is the input file for 3-phase KKS phase field model.

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

  [./xas]
    order = FIRST
    family = LAGRANGE
  [../]

  [./xnd]
    order = FIRST
    family = LAGRANGE
  [../]
[]

# Defining the equilibrium phase field profile as described in the KKS model.
[Functions]
  [./ic_func_eta]
    type = ParsedFunction
    value = (tanh(x)+1)/2
  [../]

  [./ic_func_c]
    type = ParsedFunction
    value = (tanh(x*5)+1)/2
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

[Materials]
  [./constants]
    type = GenericFunctionMaterial
    prop_names = 'M L eps_eq R G0As_p1 G0Nd_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1 dEAsAs_p1 dENdNd_p1 dENdAs_p1 dEUNd_p2 dEUAs_p2 L0UNd_p2 L0NdAs_p2 L0UAs_p2 G0U3As4_p3 G0Nd_p3 G0As_p3'
    prop_values = '0.7 0.7 0.0175 8.314 5000 5000 4.17 -3.225 -1.04 -1.44 2.60 -12.572 16.65 8.94 0.51 16.65 6.76 1000 5000 1000'
  [../]

  [./G0U_p1]
    type = DerivativeParsedMaterial
    f_name = G0U_p1
    constant_names = 'A B C D E F T'
    constant_expressions = '-8407.734 130.955151 -26.9182 1.25156e-03 -4.42605e-06 38568 300'
    function = 'A + B*T + C*T*log(T) + D*T*T + E*T*T*T + F/T'
    outputs = exodus
  [../]

  [./G0U_p2]
    type = DerivativeParsedMaterial
    f_name = G0U_p2
    constant_names = 'A B C D E F T'
    constant_expressions = '-3407.734 130.955151 -26.9182 1.25156e-03 -4.42605e-06 38568 300'
    function = 'A + B*T + C*T*log(T) + D*T*T + E*T*T*T + F/T'
    outputs = exodus
  [../]

  [./G0Nd_p2]
    type = DerivativeParsedMaterial
    f_name = G0Nd_p2
    constant_names = 'A B C D E F T'
    constant_expressions = '-7902.93 111.10239 -27.0858 0.556125e-03 -2.6923e-06 34887 300'
    function = 'A + B*T + C*T*log(T) + D*T*T + E*T*T*T + F/T'
    outputs = exodus
  [../]

  [./p1]
    type = DerivativeParsedMaterial
    f_name = p1
    args = 'xnd xas'
    #function = '(1-xnd-xas)*G0U_p1 + xnd*G0Nd_p1 + xas*G0As_p1 + 3*xas*xas*dEAsAs_p1 + 3*xnd*xnd*dENdNd_p1 + 3*xnd*xas*dENdAs_p1
    #            + R*T*((1-xnd-xas)*log(1-xnd-xas) + xnd*log(xnd) + xas*log(xas))
    #            + (1-xnd-xas)*xnd*L0UNd_p1 + (1-xnd-xas)*xas*L0UAs_p1 + xnd*xas*L0NdAs_p1'
    function = '(1-xnd-xas)*G0U_p1 + xnd*5000 + xas*5000 + 3*xas*xas*-1.44 + 3*xnd*xnd*2.6 + 3*xnd*xas*-3.225
                + 8.314*T*((1-xnd-xas)*log(1-xnd-xas) + xnd*log(xnd) + xas*log(xas))
                + (1-xnd-xas)*xnd*4.17 + (1-xnd-xas)*xas*-1.04 + xnd*xas*-3.225'
  [../]

  [./p2]
    type = DerivativeParsedMaterial
    f_name = p2
    args = 'xnd xas'
    #function = '(1-xnd-xas)*G0U_p2 #+ xnd*G0Nd_p2 + xas*G0As_p2 + 6*(1-xnd-xas)*xas*dEUNd_p2 + 6*(1-xnd-xas)*xnd*dEUAs_p2 + 6*(1-xnd-xas)*(1-xnd-xas)*dEUU_p2
    #            + 0.5*R*T*(2*(1-xnd-xas)*log(2*(1-xnd-xas)) + (1-2*(1-xnd-xas))*log(1-2*(1-xnd-xas)))
    #            + (1-xnd-xas)*xnd*L0UNd_p2 + (1-xnd-xas)*xas*L0UAs_p2 + xnd*xas*L0NdAs_p2'
    function = '(1-xnd-xas)*G0U_p2 + xnd*G0Nd_p2 + xas*G0As_p2 + 6*(1-xnd-xas)*xas*16.65 + 6*(1-xnd-xas)*xnd*8.94 + 6*(1-xnd-xas)*(1-xnd-xas)*10.0
                + 0.5*R*T*(2*(1-xnd-xas)*log(2*(1-xnd-xas)) + (1-2*(1-xnd-xas))*log(1-2*(1-xnd-xas)))
                + (1-xnd-xas)*xnd*0.51 + (1-xnd-xas)*xas*6.76 + xnd*xas*16.65'
  [../]

  [./p3]
    type = DerivativeParsedMaterial
    f_name = p3
    args = 'xnd xas'
    function = '(1-xnd-xas)*G0U3As4_p3 + xnd*G0Nd_p3 + xas*G0As_p3
                + (3/7)*R*T*((7/3)*xnd*log((7/3)*xnd) + (1-(7/3)*xnd)*log(1-(7/3)*xnd))'
  [../]

  [./h_eta]
    type = SwitchingFunction3PhaseMaterial
    h_order = HIGH
    eta = eta
  [../]

  [./g_eta]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta
  [../]

[]

[Kernels]
  [./PhaseConc]
    type = KKSPhaseConcentration
    ca       = xas
    variable = xnd
    c        = c
    eta      = eta
  [../]

  [./ChemPotSolute]
    type = KKSPhaseChemicalPotential
    variable = xas
    cb       = xnd
    fa_name  = p1
    fb_name  = p2
  [../]

  [./CHBulk]
    type = KKSSplitCHCRes
    variable = c
    ca       = xas
    cb       = xnd
    fa_name  = p1
    fb_name  = p2
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
    fa_name  = p1
    fb_name  = p2
    w       = 0.7           # DW height parameter
    args = 'xas xnd'
  [../]

  [./ACBulkC]
    type = KKSACBulkC
    variable = eta
    ca       = xas
    cb       = xnd
    fa_name  = p1
    fb_name  = p2
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
    fa_name = p1
    fb_name = p2
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
