[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 50
  ny = 50
  nz = 0
  xmin = 0
  xmax = 20
  ymin = 0
  ymax = 20
  zmin = 0
  zmax = 0
[]

[AuxVariables]
  [./Fglobal]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

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

[Functions]
  [./ic_func_eta]
    type = ParsedFunction
    value = 0.5*(1.0-tanh((x)/sqrt(2.0)))
  [../]
  [./ic_func_c]
    type = ParsedFunction
    value = '0.9*(0.5*(1.0-tanh(x/sqrt(2.0))))^3*(6*(0.5*(1.0-tanh(x/sqrt(2.0))))^2-15*(0.5*(1.0-tanh(x/sqrt(2.0))))+10)+0.1*(1-(0.5*(1.0-tanh(x/sqrt(2.0))))^3*(6*(0.5*(1.0-tanh(x/sqrt(2.0))))^2-15*(0.5*(1.0-tanh(x/sqrt(2.0))))+10))'
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
    value = 0.5
  [../]
  [./left_eta]
    type = DirichletBC
    variable = 'eta'
    boundary = 'left'
    value = 0.5
  [../]
[]

[Materials]
  [./fl]
    type = DerivativeParsedMaterial
    f_name = fl
    args = 'cl'
    function = '0.00028*cl^2-0.0000165*cl-0.00017795'
  [../]

  [./fs]
    type = DerivativeParsedMaterial
    f_name = fs
    args = 'cs'
    function = '0.000194*cs^2-0.00036*cs+0.000013231'
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
    prop_values = '0.7 0.7 1.0  '
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

  end_time = 800
  dt = 4.0
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
