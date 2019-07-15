# This file i have taken from the examples directory of MOOSE framework.

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

#[Adaptivity]
#  marker = errorfrac # this specifies which marker from 'Markers' subsection to use
#  steps = 2 # run adaptivity 2 times, recomputing solution, indicators, and markers each time
#
#  # Use an indicator to compute an error-estimate for each element:
#  [./Indicators]
#    # create an indicator computing an error metric for the convected variable
#    [./error] # arbitrary, use-chosen name
#      type = GradientJumpIndicator
#      variable = c
#      outputs = none
#    [../]
#  [../]
#
#  # Create a marker that determines which elements to refine/coarsen based on error estimates
#  # from an indicator:
#  [./Markers]
#    [./errorfrac] # arbitrary, use-chosen name (must match 'marker=...' name above
#      type = ErrorFractionMarker
#      indicator = error # use the 'error' indicator specified above
#      refine = 0.5 # split/refine elements in the upper half of the indicator error range
#      coarsen = 0 # don't do any coarsening
#      outputs = none
#    [../]
#  [../]
#[]

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

  [./cl]
    order = FIRST
    family = LAGRANGE
  [../]

  [./cs]
    order = FIRST
    family = LAGRANGE
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

#[BCs]
#  [./left_c]
#    type = DirichletBC
#    variable = 'c'
#    boundary = 'left'
#    value = 0.9
#  [../]
#
#  [./left_eta]
#    type = DirichletBC
#    variable = 'eta'
#    boundary = 'left'
#    value = 0.1
#  [../]
#[]

[Materials]
  [./fl]
    type = DerivativeParsedMaterial
    f_name = fl
    args = 'cl cs'
    function = '-0.277903*(1-cs-cl) + 100*cs + 200*cl - 4.32*cl*cl + 7.8*cs*cs - 37.716*cs*cl + 4157*((1-cs-cl)*log(1-cs-cl) + cs*log(cs) + cl*log(cl)) + 0.51*cs*(1-cs-cl) + 16.65*cs*cl + 6.76*cs*(1-cs-cl)' # This is the left parabolic equation.
  [../]

  [./fs]
    type = DerivativeParsedMaterial
    f_name = fs
    args = 'cl cs'
    function = '5000*(1-cs-cl) + 500*cs + 0.1814162*cl + 3.06*(1-cs-cl)*cs + 40.56*(1-cs-cl)*cl + 4157*((1-cs-cl)*log(1-cs-cl) + cs*log(cs) + cl*log(cl)) + 0.51*cs*(1-cs-cl) + 16.65*cs*cl + 6.76*cl*(1-cs-cl)' # This is the right parabolic equation.
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
    ca       = cl
    variable = cs
    c        = c
    eta      = eta
  [../]

  [./ChemPotSolute]
    type = KKSPhaseChemicalPotential
    variable = cl
    cb       = cs
    fa_name  = fl
    fb_name  = fs
  [../]

  [./CHBulk]
    type = KKSSplitCHCRes
    variable = c
    ca       = cl
    cb       = cs
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
    args = 'cl cs'
  [../]

  [./ACBulkC]
    type = KKSACBulkC
    variable = eta
    ca       = cl
    cb       = cs
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
