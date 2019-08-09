#
# KKS simple example in the split form
#

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

  # order parameter
  [./eta]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  [../]

  # hydrogen concentration
  [./x1]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = FunctionIC
      function = x/10
    [../]
  [../]

  [./x2]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = FunctionIC
      function = x/10
    [../]
  [../]
[]

[Materials]
  # Free energy of Phase 1
  [./F1]
    type = DerivativeParsedMaterial
    f_name = F1
    args = 'x1'
    constant_names = 'dEAsAs_p1 dENdNd_p1 dENdAs_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1'
    constant_expressions = '-1.44 2.60 -3.225 4.17 -3.225 -1.04'
    function = 'xU1:=1-x1-x1; xU1*-0.15608 + x1*0.05182 + x1*0.05182 + 3*x1*x1*dENdNd_p1
                + 8.617e-05*300*(xU1*plog(xU1,0.05) + x1*plog(x1,0.05) + x1*plog(x1,0.05))
                + xU1*x1*L0UNd_p1'
  [../]

  # Free energy of Phase 2
  [./F2]
    type = DerivativeParsedMaterial
    f_name = F2
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

[AuxKernels]
  [./GlobalFreeEnergy]
    variable = Fglobal
    type = KKSGlobalFreeEnergy
    fa_name = F1
    fb_name = F2
    w = 0.3
  [../]
[]

[VectorPostprocessors]
  [./F]
    type = LineMaterialRealSampler
    property = 'F1 F2'
    sort_by = x
    start = '0 0 0'
    end = '10 0 0'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  num_steps = 2
[]

[Problem]
  kernel_coverage_check = false
  solve = false
[]

[Outputs]
  exodus = true
  csv = true
  print_linear_residuals = true
[]
