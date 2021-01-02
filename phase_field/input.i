E = 25850     # Young's modulus [N/mm2]
nu = 0.18     # Poisson's ratio
Gc = 0.089   # energy release rate [N/mm]
l = 0.015      # Length scale [mm]
psic = 14.88  # Critical fracture energy [N-mm]
k = 1e-09     # Residual degradation
dc = 2.0      # Critical damage

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = 'fracture.i'
    app_type = raccoonApp
    execute_on = 'TIMESTEP_BEGIN'
    cli_args = 'Gc=${Gc};l=${l};psic=${psic};k=${k}'
  []
[]

[Transfers]
  [send_E_el_active]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    source_variable = 'E_el_active'
    variable = 'E_el_active'
  []
  [get_d]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = from_multiapp
    source_variable = 'd'
    variable = 'd'
  []
[]

[Mesh]
  [file_mesh]
    type = FileMeshGenerator
    file = '../mesh/10k_linear.inp'
  []
  construct_node_list_from_side_list = false # prevents from erronously adding side nodes to the alphabetically first nodeset
#   [scaled]
#     type = TransformGenerator
#     input = file_mesh
#     transform = SCALE
#     vector_value = '0.002 0.002 0.002'
#   []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [d]
  []
  [E_el_active]
    order = CONSTANT
    family = MONOMIAL
  []
  [fy]
  []
[]

[AuxKernels]
  [E_el]
    type = ADMaterialRealAux
    variable = 'E_el_active'
    property = 'E_el_active'
    execute_on = 'TIMESTEP_END'
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = 'disp_x'
    component = 0
    displacements = 'disp_x disp_y disp_z'
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = 'disp_y'
    component = 1
    displacements = 'disp_x disp_y disp_z'
    save_in = 'fy'
  []
  [solid_z]
    type = ADStressDivergenceTensors
    variable = 'disp_z'
    component = 2
    displacements = 'disp_x disp_y disp_z'
  []
[]

[BCs]
  [ydisp]
    type = FunctionDirichletBC
    variable = 'disp_y'
    boundary = 'load'
    function = 't'
    preset = false
  []
  [xfix]
    type = DirichletBC
    variable = 'disp_x'
    boundary = 'bottom'
    value = 0
  []
  [yfix]
    type = DirichletBC
    variable = 'disp_y'
    boundary = 'bottom'
    value = 0
  []
  [zfix]
    type = DirichletBC
    variable = 'disp_z'
    boundary = 'bottom'
    value = 0
  []
  [sym_z]
    type = DirichletBC
    variable = 'disp_z'
    boundary = 'zsym'
    value = 0 
  []
[]

[Materials]
  [elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  []
  [strain]
    type = ADComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
  []
  [stress]
    type = SmallStrainDegradedElasticPK2Stress_StrainSpectral
    d = 'd'
    d_crit = ${dc}
  []
  [fracture_properties]
    type = ADGenericFunctionMaterial
    prop_names = 'energy_release_rate phase_field_regularization_length critical_fracture_energy'
    prop_values = '${Gc} ${l} ${psic}'
  []
  [local_dissipation]
    type = LinearLocalDissipation
    d = d
  []
  [phase_field_properties]
    type = ADFractureMaterial
    local_dissipation_norm = 8/3
  []
  [degradation]
    type = QuadraticDegradation
    # type = LorentzDegradation
    d = d
    residual_degradation = ${k}
  []
[]

[Executioner]
  type = TransientSubcycling
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'

  dt = 1e-4
  # num_steps = 10

  # dtmin = 1e-7
  # dtmax = 1e-2
  end_time = 1.0
  # num_steps = 100

  # [TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 1e-2
  # []

  nl_abs_tol = 1e-08
  nl_rel_tol = 1e-06

  automatic_scaling = true

  picard_max_its = 100
  picard_abs_tol = 1e-50
  picard_rel_tol = 1e-03
  accept_on_max_picard_iteration = true
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = 'fy'
    boundary = 'bottom'
  []
[]

[Outputs]
  print_linear_residuals = false
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  [csv]
    type = CSV
    file_base = 'fd'
  []
  [exodus]
    type = Exodus
    file_base = 'pv'
  []
  [console]
    type = Console
    outlier_variable_norms = false
  []
[]
