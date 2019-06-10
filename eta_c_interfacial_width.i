[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 1000
  ny = 1
  nz = 0
  xmin = 0
  xmax = 25
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 0
[]

[AuxVariables]
  [./c]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./fe]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[Variables]
  #[./c]
    #order = FIRST
    #family = LAGRANGE
  #[../]
  #[./w]
    #order = FIRST
    #family = LAGRANGE
  #[../]
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  [./testIC]
    type = FunctionIC
    variable = c
    function = x/25
  [../]
  [./test2IC]
    type = FunctionIC
    variable = eta
    function = (25-x)/25
  [../]
[]

[BCs]
  [./Periodic]
    [./c_bcs]
      auto_direction = 'y'
    [../]
  [../]
[]

[Kernels]
  #active = ' '
  #[./w_dot]
    #variable = w
    #v = c
    #type = CoupledTimeDerivative
  #[../]
  #[./coupled_res]
    #variable = w
    #type = SplitCHWRes
    #mob_name = M
  #[../]
  #[./coupled_parsed]
    #variable = c
    #type = SplitCHParsed
    #f_name = f_loc
    #kappa_name = kappa_c
    #args = eta
    #w = w
  #[../]
  #[./c_dot]
    #variable = w
    #type = CoupledTimeDerivative
    #v = c
  #[../]

  [./acinterface]
    variable = eta
    type = ACInterface
    kappa_name = kappa_op
    mob_name = L
  [../]
  [./allencahn]
    variable = eta
    type = AllenCahn
    f_name = f_loc
    args = c
  [../]
  [./eta_dot]
    type = TimeDerivative
    variable = eta
  [../]
[]

[AuxKernels]
  [./fe]
    type = TotalFreeEnergy
    variable = fe
    f_name = 'f_loc'
    kappa_names = 'kappa_c'
    interfacial_vars = c
  [../]
[]

[Materials]
  [./constants]
    type = GenericFunctionMaterial
    prop_names = 'kappa_c M kappa_op L'
    prop_values = '8.125e-16*6.24150934e+18*1e+09^2*1e-27
                   2.2841e-26*1e+09^2/6.24150934e+18/1e-27
                   1.25
                   2.5'
                   # kappa_c*eV_J*nm_m^2*d
                   # M*nm_m^2/eV_J/d
  [../]
  [./local_energy]
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = 'c eta'
    constant_names = 'A   B   C   D   E   F   G'
    constant_expressions = '0.0000260486 0.0000239298 -0.000178164 0.000196227 -0.000365148 0.0000162483 -50'
    function = '(3*eta^2-2*eta^3)*(A*c^2+B*c+C) + (1-(3*eta^2-2*eta^3))*(D*c^2+E*c+F) + G*eta^2*(1-eta)^2'
    #function = '(3*eta^2-2*eta^3)*(D*c^2+E*c+F) + (1-(3*eta^2-2*eta^3))*(A*c^2+B*c+C) + G*eta^2*(1-eta)^2'
    outputs = exodus
  [../]
[]

#[VectorPostprocessors]
#  [./F]
#    type = LineMaterialRealSampler
#    property = f_loc
#    start = '0 0.5 0'
#    end = '25 0.5 0'
#    sort_by = x
#  [../]
#[]

[Preconditioning]
  [./coupled]
    type = SMP
    full = true
  [../]
[]

#[Problem]
#  kernel_coverage_check = false
#  solve = false
#[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  l_max_its = 30
  l_tol = 1e-6
  nl_max_its = 50
  nl_abs_tol = 1e-12

  # petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type
  #                        -sub_pc_type -pc_asm_overlap'
  # petsc_options_value = 'asm      31                  preonly
  #                        ilu          1'

  num_steps = 10000

  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    iteration_window = 2
    dt = 100
  [../]
[]

[Outputs]
  exodus = true
  console = true
  csv = true
[]
