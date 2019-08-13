# Simple KKS file

[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 200
  ny = 2
  nz = 0
  xmin = -10
  xmax = 10
  ymin = 0
  ymax = 2
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
  # phase 1 solute concentration
  [./xAs1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.42
  [../]
  [./xNd1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.72
  [../]
  # phase 2 solute concentration
  [./xAs2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.42
  [../]
  [./xNd2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.72
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
    #type = RandomIC
    #min = 0.1
    #max = 0.9
  [../]
  [./xAs]
    variable = xAs
    type = FunctionIC
    function = ic_func_c
    #type = RandomIC
    #min = 0.24
    #max = 0.26
  [../]
  [./xNd]
    variable = xNd
    type = FunctionIC
    function = ic_func_c
    #type = RandomIC
    #min = 0.24
    #max = 0.26
  [../]
[]

[Materials]
  # Free energy of phase 1
  [./f1]
    type = DerivativeParsedMaterial
    f_name = f1
    args = 'xAs1 xNd1'
    constant_names = 'dEAsAs_p1 dENdNd_p1 dENdAs_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1'
    constant_expressions = '-1.44 -3.84 -3.225 4.17 -3.225 -1.04'
    # function = 'xU1:=1-xAs1-xNd1; xU1*-0.15608 + 50*xAs1^2 + 50*xNd1^2'
    function = 'xU1:=1-xAs1-xNd1; xU1*-0.15608 + xNd1*0.05182 + xAs1*0.05182
                + 8.617e-05*300*(xU1*plog(xU1,0.1) + xNd1*plog(xNd1,0.0001) + xAs1*plog(xAs1,0.0001))
                + xU1*xNd1*L0UNd_p1'
                #+ 3*xNd1*xNd1*dENdNd_p1
  [../]

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
    ca       = xAs1
    variable = xAs2
    c        = xAs
    eta      = eta
  [../]
  [./PhaseConc2]
    type = KKSPhaseConcentration
    ca       = xNd1
    variable = xNd2
    c        = xNd
    eta      = eta
  [../]
  # enforce pointwise equality of chemical potentials
  [./ChemPotSolute1]
    type = KKSPhaseChemicalPotential
    variable = xAs1
    cb       = xAs2
    args_a = xNd1
    args_b = xNd2
    fa_name  = f1
    fb_name  = f2
  [../]
  [./ChemPotSolute2]
    type = KKSPhaseChemicalPotential
    variable = xNd1
    cb       = xNd2
    args_a = xAs1
    args_b = xAs2
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
  [./CHBulk1]
    type = KKSSplitCHCRes
    variable = xAs
    ca       = xAs1
    cb       = xAs2
    args_a = xNd1
    fa_name  = f1
    fb_name  = f2
    w        = wAs
  [../]
  [./CHBulk2]
    type = KKSSplitCHCRes
    variable = xNd
    ca       = xNd1
    cb       = xNd2
    args_a = 'xNd2 xAs1'
    fa_name  = f1
    fb_name  = f2
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
    fa_name  = f1
    fb_name  = f2
    w        = 1.0
    args = 'xAs1 xAs2 xNd1 xNd2'
  [../]
  [./ACBulkC1]
    type = KKSACBulkC
    variable = eta
    ca       = xAs1
    cb       = xAs2
    args = 'xNd1 xNd2'
    fa_name  = f1
    fb_name  = f2
  [../]
  [./ACBulkC2]
    type = KKSACBulkC
    variable = eta
    ca       = xNd1
    cb       = xNd2
    args = 'xAs1 xAs2'
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
