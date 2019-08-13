# Simple KKS file

[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 100
  ny = 100
  nz = 0
  xmin = -10
  xmax = 10
  ymin = -10
  ymax = 10
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
  [./xAs]
    order = FIRST
    family = LAGRANGE
  [../]
  [./xNd]
    order = FIRST
    family = LAGRANGE
  [../]
  # chemical potential
  [./wAs]
    order = FIRST
    family = LAGRANGE
  [../]
  [./wNd]
    order = FIRST
    family = LAGRANGE
  [../]
  # phase 2 solute concentration
  [./xAs2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  [../]
  [./xNd2]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0
  [../]
  # phase 3 solute concentration
  [./xAs3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.5
  [../]
  [./xNd3]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0.5
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
    #type = FunctionIC
    #function = ic_func_eta
    type = RandomIC
    min = 0.4
    max = 0.6
  [../]
  [./xAs]
    variable = xAs
    type = FunctionIC
    function = 0.5
    #type = RandomIC
    #min = 0
    #max = 0.5
  [../]
  [./xNd]
    variable = xNd
    type = FunctionIC
    function = ic_func_c
    #type = RandomIC
    #min = 0
    #max = 0.5
  [../]
  [./xNd2]
    variable = xNd2
    type = RandomIC
    min = 0.1
    max = 0.9
  [../]
  [./xNd3]
    variable = xNd3
    type = RandomIC
    min = 0.1
    max = 0.9
  [../]
[]

[Materials]
  # Free energy of phase 2
  [./f2]
    type = DerivativeParsedMaterial
    f_name = f2
    args = 'xAs2 xNd2'
    constant_names = 'dENdAs factor1 L0UNd_p2 L0UAs_p2 L0NdAs_p2'
    constant_expressions = '-1.57 200 1.01 11.38 16.65'
    function = 'xU2:=1-xAs2-xNd2; 0.5*-0.21585 + 0.5*-0.263903 + dENdAs
                + factor1*((xAs2-0.5)^2 + (xNd2-0.5)^2)
                + 0
                + 0'
  [../]

  # Free energy of phase 3
  [./f3]
    type = DerivativeParsedMaterial
    f_name = f3
    args = 'xAs3 xNd3'
    constant_names = 'factor2 L0UNd_p3 L0NdAs_p3 L0UAs_p3'
    constant_expressions = '100 -1.46 3.60 3.52'
    function = 'xU3:=1-xAs3-xNd3; 0.5*-0.08724 + 0.5*-0.26 + -1.03
                + factor2*((0.5-xNd3-xAs3)*(0.5-xNd3-xAs3) + (xAs3-0.5)*(xAs3-0.5))
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
  [./PhaseConc1]
    type = KKSPhaseConcentration
    ca       = xAs2
    variable = xAs3
    c        = xAs
    eta      = eta
  [../]
  [./PhaseConc2]
    type = KKSPhaseConcentration
    ca       = xNd2
    variable = xNd3
    c        = xNd
    eta      = eta
  [../]
  # enforce pointwise equality of chemical potentials
  [./ChemPotSolute1]
    type = KKSPhaseChemicalPotential
    variable = xAs2
    cb       = xAs3
    args_a = xNd2
    args_b = xNd3
    fa_name  = f2
    fb_name  = f3
  [../]
  [./ChemPotSolute2]
    type = KKSPhaseChemicalPotential
    variable = xNd2
    cb       = xNd3
    args_a = xAs2
    args_b = xAs3
    fa_name  = f2
    fb_name  = f3
  [../]
# c -> cAs, cNd
# w -> wAs, wNd
# x1 -> x1As x1Nd
# x2 -> x2As x2Nd

  #
  # Cahn-Hilliard Equation
  #
  [./CHBulk1]
    type = KKSSplitCHCRes
    variable = xAs
    ca       = xAs2
    cb       = xAs3
    args_a = xNd2
    fa_name  = f2
    fb_name  = f3
    w        = wAs
  [../]
  [./CHBulk2]
    type = KKSSplitCHCRes
    variable = xNd
    ca       = xNd2
    cb       = xNd3
    args_a = xAs2
    fa_name  = f2
    fb_name  = f3
    w        = wNd
  [../]

  [./dcdt1]
    type = CoupledTimeDerivative
    variable = wAs
    v = xAs
  [../]
  [./dcdt2]
    type = CoupledTimeDerivative
    variable = wNd
    v = xNd
  [../]
  [./ckernel1]
    type = SplitCHWRes
    mob_name = M
    variable = wAs
  [../]
  [./ckernel2]
    type = SplitCHWRes
    mob_name = M
    variable = wNd
  [../]
  #
  # Allen-Cahn Equation
  #
  [./ACBulkF]
    type = KKSACBulkF
    variable = eta
    fa_name  = f2
    fb_name  = f3
    w        = 1.0
    args = 'xAs2 xAs3 xNd2 xNd3'
  [../]
  [./ACBulkC1]
    type = KKSACBulkC
    variable = eta
    ca       = xAs2
    cb       = xAs3
    args = 'xNd2 xNd3'
    fa_name  = f2
    fb_name  = f3
  [../]
  [./ACBulkC2]
    type = KKSACBulkC
    variable = eta
    ca       = xNd2
    cb       = xNd3
    args = 'xAs2 xAs3'
    fa_name  = f2
    fb_name  = f3
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
    fa_name = f2
    fb_name = f3
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
  nl_max_its = 1000
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
  print_linear_residuals = false
[]
