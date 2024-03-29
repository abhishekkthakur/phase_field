# Simple KKS file

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

[AuxVariables]
  [./Fglobal]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Variables]
  # order parameter
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]

  # Global concentration
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]

  # chemical potential
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]

  # phase 1 solute concentration
  [./x1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.25
  [../]
  # phase 2 solute concentration
  [./x2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.25
  [../]
[]

[Functions]
  [./ic_func_eta]
    type = ParsedFunction
    value = 0.5*(1.0-tanh(x/sqrt(2.0)))
  [../]
  [./ic_func_c]
    type = ParsedFunction
    value = 0.25*(1.0-tanh(x/sqrt(2.0)))
  [../]
[]

[ICs]
  [./eta]
    variable = eta
    type = FunctionIC
    function = ic_func_eta
  [../]
  [./c]
    variable = c
    # type = FunctionIC
    # function = ic_func_c
    type = RandomIC
    min = 0.24
    max = 0.26
  [../]
[]

[Materials]
  # Free energy of phase 1
  [./f1]
    type = DerivativeParsedMaterial
    f_name = f1
    args = 'x1'
    constant_names = 'dEAsAs_p1 dENdNd_p1 dENdAs_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1'
    constant_expressions = '-1.44 2.60 -3.225 4.17 -3.225 -1.04'
    function = 'xU1:=1-x1-x1; xU1*-0.15608 + 100*x1^2'
  [../]

  # Free energy of phase 2
  [./f2]
    type = DerivativeParsedMaterial
    f_name = f2
    args = 'x2'
    constant_names = 'dENdAs factor1 L0UNd_p2 L0UAs_p2 L0NdAs_p2'
    constant_expressions = '-1.57 200 1.01 11.38 16.65'
    function = 'xU2:=1-x2-x2; 0.5*-0.21585 + 0.5*-0.263903 + dENdAs + factor1*((x2-0.5)*(x2-0.5) + (x2-0.5)*(x2-0.5))
                + 0
                + 0'
  [../]

  # h(eta)
  [./h_eta]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = eta
  [../]

  # g(eta)
  [./g_eta]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta
  [../]

  # constant properties
  [./constants]
    type = GenericConstantMaterial
    prop_names  = 'M   L   eps_sq'
    prop_values = '0.7 0.7 1.0  '
  [../]
[]

[Kernels]
  # enforce c = (1-h(eta))*cl + h(eta)*cs
  [./PhaseConc]
    type = KKSPhaseConcentration
    ca       = x1
    variable = x2
    c        = c
    eta      = eta
  [../]

  # enforce pointwise equality of chemical potentials
  [./ChemPotSolute]
    type = KKSPhaseChemicalPotential
    variable = x1
    cb       = x2
    fa_name  = f1
    fb_name  = f2
  [../]

# c -> cAs, cNd
# w -> wAs, wNd
# x1 -> x1As x1Nd
# x2 -> x2As x2Nd

  #
  # Cahn-Hilliard Equation
  #
  [./CHBulk]
    type = KKSSplitCHCRes
    variable = c
    ca       = x1
    cb       = x2
    fa_name  = f1
    fb_name  = f2
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

  #
  # Allen-Cahn Equation
  #
  [./ACBulkF]
    type = KKSACBulkF
    variable = eta
    fa_name  = f1
    fb_name  = f2
    w        = 1.0
    args = 'x1 x2'
  [../]
  [./ACBulkC]
    type = KKSACBulkC
    variable = eta
    ca       = x1
    cb       = x2
    fa_name  = f1
    fb_name  = f2
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
    fa_name = f1
    fb_name = f2
    w = 1.0
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON #'PJFNK'
  # petsc_options_iname = '-pc_type -sub_pc_type   -sub_pc_factor_shift_type'
  # petsc_options_value = 'asm       ilu            nonzero'
  petsc_options_iname = '-pc_type  -pc_factor_shift_type'
  petsc_options_value = 'lu        nonzero'
  l_max_its = 100
  nl_max_its = 150
  l_tol = 1.0e-8
  nl_rel_tol = 1.0e-9
  nl_abs_tol = 1.0e-9
  end_time = 1e10

  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    iteration_window = 2
    growth_factor = 1.5
    dt = 1e-5
  [../]
  [./Predictor]
    type = SimplePredictor
    scale = 0.5
  [../]

[]

[Preconditioning]
  active = 'full'
  [./full]
    type = SMP
    full = true
  [../]
  [./mydebug]
    type = FDP
    full = true
  [../]
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]
