# This is for phase 1 and phase 2 equilibrium.

# This file is for KKS model implemented for 3 phase, 2 global concentration and 9 local
# concentrations. We have used 6 local concentrations as 3 are defined implicitly.

# Mesh and node generation part.
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 200
  ny = 1
  nz = 0
  xmin = -10
  xmax = 10
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

# Energy declaration part.
[AuxVariables]
  [./Energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

# Variable declaration part.
[Variables]
  # Global concentrations.
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]

  # order parameters. eta1, eta2 and eta3 for phase 1, phase 2 and phase 3 respectively.
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]

  # Local concentration of As in Phase 1.
  [./xAs1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.002
    #initial_condition = 0.7
  [../]
  # Local concentration of Nd in Phase 1.
  [./xNd1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.01
    #initial_condition = 0.1
  [../]
  # Local concentration of As in Phase 2.
  [./xAs2]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = FunctionIC
      function = f_c
    [../]
  [../]
  # Local concentration of Nd in Phase 2.
  [./xNd2]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = FunctionIC
      function = f_c
    [../]
  [../]
  # Lagrange multiplier
  [./lambda]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
[]

[Functions]
  [./f_eta]
    type = ParsedFunction
    #value = (-tanh(x+5)+1)/2
    value = (-tanh(4*x)+1)/2
  [../]
  [./f_c]
    type = ParsedFunction
    #value = x/180
    value = (1+tanh(x))/2*0.49+0.005
  [../]
[]

# Initial condition block. This is very important.
[ICs]
  [./eta]
    variable = eta
    type = FunctionIC
    function = f_eta
  [../]
  [./c]
    variable = c
    type = FunctionIC
    function = f_c
  [../]
[]

# Materials block. Here we define free energy expression for each phase as a function of local
# compositions of that phase.
[Materials]
  [./f1]
    type = DerivativeParsedMaterial
    f_name = F1
    args = 'xAs1 xNd1'

    constant_names = 'dEAsAs_p1 dENdNd_p1 dENdAs_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1'
    constant_expressions = '-1.44 2.60 -3.225 4.17 -3.225 -1.04'
    function = 'xU1:=1-xAs1-xNd1; xU1*-0.15608 + xNd1*0.05182 + xAs1*0.05182 + 3*xNd1*xNd1*dENdNd_p1
                + 8.617e-05*300*(xU1*plog(xU1,0.01) + xNd1*plog(xNd1,0.01) + xAs1*plog(xAs1,0.01))
                + xU1*xNd1*L0UNd_p1'
  [../]
  [./f2]
    type = DerivativeParsedMaterial
    f_name = F2
    args = 'xAs2 xNd2'
    constant_names = 'dENdAs factor1 L0UNd_p2 L0UAs_p2 L0NdAs_p2'
    constant_expressions = '-1.57 200 1.01 11.38 16.65'
    function = 'xU2:=1-xAs2-xNd2; 0.5*-0.21585 + 0.5*-0.263903 + dENdAs + factor1*((xNd2-0.5)*(xNd2-0.5) + (xAs2-0.5)*(xAs2-0.5))
                + 0
                + 0'

  [../]

  # Switching function.
  [./h_eta]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = eta
  [../]

  # Coefficients for diffusion equation
  [./Dh]
    type = DerivativeParsedMaterial
    material_property_names = 'D h_eta'
    function = D*h_eta
    f_name = Dh_eta
    args = 'eta'
  [../]

  # Barrier function
  [./g]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta
    function_name = g
  [../]

  # constant properties
  [./constants]
    type = GenericConstantMaterial
    prop_names  = 'L   kappa  D'
    prop_values = '0.7 1      1'
  [../]
[]

[Kernels]
  #Kernels for diffusion equation

  # This is for global concentration.
  [./diff_time_1]      # This is the time derivative for the global concentration.
    type = TimeDerivative
    variable = c
  [../]
  [./diff_c1_1]       # This is the divergence of summation of the product of h and c. Check MatDiffusion to clarify.
    type = MatDiffusion
    variable = c
    #diffusivity = Dh1
    diffusivity = Dh_eta
    args = 'eta'
    #v = xNd1
  [../]

  # Kernels for Allen-Cahn equation for eta for global concentrations c.
  [./deta1dt_1]
    type = TimeDerivative
    variable = eta
  [../]
  [./ACBulkF1_1]
    type = KKSMultiACBulkF
    variable  = eta
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    gi_name   = g
    eta_i     = eta
    wi        = 1
    args      = 'xNd1 xNd2 xAs1 xAs2 eta'
  [../]
  [./ACBulkC1_1]
    type = KKSMultiACBulkC
    variable  = eta
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    cj_names  = 'xNd1 xNd2'
    eta_i     = eta
    #args      = 'eta2 eta3'
    args      = 'xAs1 xAs2 eta'
  [../]
  [./ACBulkC1_2]
    type = KKSMultiACBulkC
    variable  = eta
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    cj_names  = 'xAs1 xAs2'
    eta_i     = eta
    #args      = 'eta2 eta3'
    args      = 'xNd1 xNd2 eta'
  [../]
  [./ACInterface1_1]
    type = ACInterface
    variable = eta
    kappa_name = kappa
  [../]
  [./multipler1_1]
    type = MatReaction
    variable = eta
    v = lambda
    mob_name = L
  [../]

  # Kernels for the Lagrange multiplier equation for both .
  [./mult_lambda_1]
    type = MatReaction
    variable = lambda
    mob_name = 1
  [../]
  [./mult_ACBulkF_1_1]
    type = KKSMultiACBulkF
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    gi_name   = g
    eta_i     = eta
    wi        = 1
    mob_name  = 1
    args      = 'xNd1 xNd2 xAs1 xAs2 eta'
  [../]
  [./mult_ACBulkC_1_1]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    cj_names  = 'xNd1 xNd2'
    eta_i     = eta
    #args = 'eta2 eta3'
    args      = 'xAs1 xAs2 eta'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_1_2]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    cj_names  = 'xAs1 xAs2'
    eta_i     = eta
    #args = 'eta2 eta3'
    args      = 'xNd1 xNd2 eta'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_1_1]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_2_1]
    type = KKSMultiACBulkF
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    gi_name   = g
    eta_i     = eta
    wi        = 1
    mob_name  = 1
    args      = 'xNd1 xNd2 xAs1 xAs2 eta'
  [../]
  [./mult_ACBulkC_2_1]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    cj_names  = 'xNd1 xNd2'
    eta_i     = eta
    #args = 'eta1 eta3'
    args      = 'xAs1 xAs2 eta'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_2_2]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    cj_names  = 'xAs1 xAs2'
    eta_i     = eta
    #args = 'eta1 eta3'
    args      = 'xNd1 xNd2 eta'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_2_1]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_3_1]
    type = KKSMultiACBulkF
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    gi_name   = g
    eta_i     = eta
    wi        = 1
    mob_name  = 1
    args      = 'xNd1 xNd2 xAs1 xAs2 eta'
  [../]
  [./mult_ACBulkC_3_1]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    cj_names  = 'xNd1 xNd2'
    eta_i     = eta
    #args = 'eta1 eta2'
    args      = 'xAs1 xAs2 eta'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_3_2]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2'
    hj_names  = 'h_eta h_eta'
    cj_names  = 'xAs1 xAs2'
    eta_i     = eta
    #args = 'eta1 eta2'
    args      = 'xNd1 xNd2 eta'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_3_1]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta
    kappa_name = kappa
    mob_name = 1
  [../]

  # Phase concentration constraints for global concentration 1.
  [./chempot12_1]
    type = KKSPhaseChemicalPotential
    variable = xAs1
    cb       = xAs2
    args_a = 'xNd1'
    args_b = 'xNd2'
    fa_name  = F1
    fb_name  = F2
  [../]

  [./phaseconcentration_1]
    type = KKSMultiPhaseConcentration
    variable = xNd1
    cj       = 'xAs1 xAs2'
    hj_names = 'h_eta h_eta'
    etas = 'eta eta'
    c = c
  [../]

  [./phaseconcentration_2]
    type = KKSMultiPhaseConcentration
    variable = xNd2
    cj       = 'xNd1 xNd2'
    hj_names = 'h_eta h_eta'
    etas = 'eta eta'
    c = c
  [../]
[]


[AuxKernels]
  [./Energy_total]
    type = KKSMultiFreeEnergy
    Fj_names = 'F1 F2'
    hj_names = 'h_eta h_eta'
    gj_names = 'g g'
    variable = Energy
    w = 1
    interfacial_vars =  'eta eta'
    kappa_names =       'kappa kappa'
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
