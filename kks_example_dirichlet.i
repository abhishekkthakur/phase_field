# This file i have taken from the examples directory of MOOSE framework.

[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 500
  ny = 1
  nz = 0
  xmin = 0
  xmax = 20
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
    initial_condition = 0.1
  [../]

  [./cs]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.9
  [../]
[]

# Defining the equilibrium phase field profile as described in the KKS model.
[Functions]
  [./ic_func_eta]
    type = ParsedFunction
    value = x/20
    #value = 0.5*(1.0-tanh((x)/sqrt(2.0)))
  [../]

  [./ic_func_c]
    type = ParsedFunction
    value = (20-x)/20
    #value = 0.9*(0.5*(1.0-tanh(x/sqrt(2.0))))^3*(6*(0.5*(1.0-tanh(x/sqrt(2.0))))^2-15*(0.5*(1.0-tanh(x/sqrt(2.0))))+10)+0.1*(1-(0.5*(1.0-tanh(x/sqrt(2.0))))^3*(6*(0.5*(1.0-tanh(x/sqrt(2.0))))^2-15*(0.5*(1.0-tanh(x/sqrt(2.0))))+10))
  [../]
[]

[ICs]
  [./eta]
    variable = eta
    type = FunctionIC
    #type = RandomIC
    function = ic_func_eta
  [../]
  [./c]
    variable = c
    type = FunctionIC
    #type = RandomIC
    function = ic_func_c
  [../]
[]

[BCs]
  [./left_c]
    type = DirichletBC
    variable = 'c'
    boundary = 'left'
    value = 0.9
  [../]

  [./left_eta]
    type = DirichletBC
    variable = 'eta'
    boundary = 'left'
    value = 0.1
  [../]
[]

[Materials]
  [./fl]
    type = DerivativeParsedMaterial
    f_name = fl
    args = 'cl'
    function = '0.0000260486*cl^2+0.0000239298*cl-0.000178164' # This is the left parabolic equation.
  [../]

  [./fs]
    type = DerivativeParsedMaterial
    f_name = fs
    args = 'cs'
    function = '0.000196227*cs^2-0.000365148*cs+0.0000162483' # This is the right parabolic equation.
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
    prop_values = '0.7 0.7 0.1  '    # Don't know what values to take for M, L and eps_sq
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
    w        = 1.0
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
    w = 1.0
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      ilu          nonzero'

  l_max_its = 100
  nl_max_its = 100
  nl_abs_tol = 1e-10

  end_time = 100
  dt = 1.0
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

  [./integral]
    type = ElementL2Error
    variable = eta
    function = ic_func_eta
  [../]
[]

[Outputs]
  exodus = true
  console = true
  gnuplot = true
[]
