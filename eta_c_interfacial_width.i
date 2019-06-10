#
# Simulation of an iron-chromium alloy using simplest possible code and a test
# set of initial conditions.
#

[Mesh]
  # generate a 2D, 25nm x 25nm mesh
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

[Variables]
  [./c]   # Mole fraction of Cr (unitless)
    order = FIRST
    family = LAGRANGE
  [../]
  [./w]   # Chemical potential (eV/mol)
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  # Use a bounding box IC at equilibrium concentrations to make sure the
  # model behaves as expected.
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
  # periodic BC as is usually done on phase-field models
  [./Periodic]
    [./c_bcs]
      auto_direction = 'y'
    [../]
  [../]
[]

[Kernels]
  # See wiki page "Developing Phase Field Models" for more information on Split
  # Cahn-Hilliard equation kernels.
  # http://mooseframework.org/wiki/PhysicsModules/PhaseField/DevelopingModels/
  #active = ' '
  [./w_dot]
    variable = w
    v = c
    type = CoupledTimeDerivative
  [../]
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
  [./timederivative]
    variable = w
    type = TimeDerivative
  [../]
  [./acinterface]
    variable = w
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
[]

[Materials]
  # d is a scaling factor that makes it easier for the solution to converge
  # without changing the results. It is defined in each of the materials and
  # must have the same value in each one.
  [./constants]
    # Define constant values kappa_c and M. Eventually M will be replaced with
    # an equation rather than a constant.
    type = GenericFunctionMaterial
    prop_names = 'kappa_c M kappa_op L'
    prop_values = '8.125e-16*6.24150934e+18*1e+09^2*1e-27
                   2.2841e-26*1e+09^2/6.24150934e+18/1e-27
                   100
                   0.001'
                   # kappa_c*eV_J*nm_m^2*d
                   # M*nm_m^2/eV_J/d
  [../]
  [./local_energy]
    # Defines the function for the local free energy density as given in the
    # problem, then converts units and adds scaling factor.
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = 'c eta'
    constant_names = 'A   B   C   D   E   F   G'
    constant_expressions = '0.0000260486 0.0000239298 -0.000178164 0.000196227 -0.000365148 0.0000162483 0.00'
    function = '(3*eta^2-2*eta^3)*(A*c^2+B*c+C) + (1-(3*eta^2-2*eta^3))*(D*c^2+E*c+F) + G*eta^2*(1-eta)^2'
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
  # Preconditioning is required for Newton's method. See wiki page "Solving
  # Phase Field Models" for more information.
  # http://mooseframework.org/wiki/PhysicsModules/PhaseField/SolvingModels/
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
