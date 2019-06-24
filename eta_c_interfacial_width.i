width = 25
[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 200
  ny = 200
  nz = 0
  xmin = 0
  xmax = ${width}
  ymin = 0
  ymax = ${width}
  zmin = 0
  zmax = 0
[]

#[AuxVariables]
#  [./c]
#    family = LAGRANGE
#    order = FIRST
#  [../]
#  [./fe]
#    family = MONOMIAL
#    order = CONSTANT
#  [../]
#[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./f_tot]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[AuxKernels]
  [./f_tot]
    type = TotalFreeEnergy
    variable = f_tot
    kappa_names = kappa_c
    interfacial_vars = c
    f_name = f_loc
  [../]
[]

[ICs]
  [./testIC]
    type = RandomIC
    variable = c
    #function = x/${width}
  [../]
  [./test2IC]
    type = RandomIC
    variable = eta
    #function = (${width}-x)/${width}
  [../]
[]

[BCs]
  [./Periodic]
    [./c_bcs]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Kernels]
  [./coupled_res]
    variable = w
    type = SplitCHWRes
    mob_name = M
  [../]
  [./coupled_parsed]
    variable = c
    type = SplitCHParsed
    f_name = f_loc
    kappa_name = kappa_c
    args = eta
    w = w
  [../]
  [./c_dot]
    variable = w
    type = CoupledTimeDerivative
    v = c
  [../]
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

[Materials]
  [./constants]
    type = GenericFunctionMaterial
    prop_names = 'kappa_c M kappa_op L'
    prop_values = '8.125e-16*6.24150934e+18*1e+09^2*1e-27
                   2.2841e-26*1e+09^2/6.24150934e+18/1e-27
                   8.125e-16*6.24150934e+18*1e+09^2*1e-27
                   2.2841e-27*1e+09^2/6.24150934e+18/1e-27'
                   # kappa_c*eV_J*nm_m^2*d
                   # M*nm_m^2/eV_J/d
  [../]
  [./local_energy]
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = 'c eta'
    constant_names = 'A   B   C   D   E   F   G'
    constant_expressions = '0.0000260486 0.0000239298 -0.000178164 0.000196227 -0.000365148 0.0000162483 0.00'
    function = '(3*eta^2-2*eta^3)*(A*c^2+B*c+C) + (1-(3*eta^2-2*eta^3))*(D*c^2+E*c+F) + G*eta^2*(1-eta)^2'
    #function = '(3*eta^2-2*eta^3)*(D*c^2+E*c+F) + (1-(3*eta^2-2*eta^3))*(A*c^2+B*c+C) + G*eta^2*(1-eta)^2'
    outputs = exodus
  [../]
[]

#[VectorPostprocessors]
# [./f_loc_sampler]
#   type = LineMaterialRealSampler
#   property = f_loc
#   start = '0 0.5 0'
#   end = '${width} 0.5 0'
#   sort_by = x
# [../]
# [./f_tot_sampler]
#   type = LineValueSampler
#   variable = 'f_tot c'
#   start_point = '0 0.5 0'
#   end_point = '${width} 0.5 0'
#   num_points = 500
#   sort_by = x
# [../]
#[]

#[Postprocessors]
#  [./F_tot]
#    type = ElementIntegralVariablePostprocessor
#    variable = f_tot
#  [../]
#  [./C]
#    type = ElementIntegralVariablePostprocessor
#    variable = c
#  [../]
#  [./c_avg_left_value]
#    type = SideAverageValue
#    variable = c
#    boundary = left
#  [../]
#  [./c_avg_right_value]
#    type = SideAverageValue
#    variable = c
#    boundary = right
#  [../]
#  [./eta_avg_left_value]
#    type = SideAverageValue
#    variable = eta
#    boundary = left
#  [../]
#  [./eta_avg_right_value]
#    type = SideAverageValue
#    variable = eta
#    boundary = right
#  [../]
#[]

[Preconditioning]
  [./coupled]
    type = SMP
    full = true
  [../]
[]

[Problem]
  # kernel_coverage_check = false
  # solve = false
[]

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

  num_steps = 200

  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    growth_factor = 1.5
    iteration_window = 2
    dt = 10
  [../]
[]

[Outputs]
  exodus = true
  console = true
  csv = true
[]
