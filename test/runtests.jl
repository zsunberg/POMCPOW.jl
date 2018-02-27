using POMCPOW
using Base.Test

using POMDPModels
using POMDPToolbox
using ParticleFilters
using D3Trees

solver = POMCPOWSolver()

pomdp = BabyPOMDP()

test_solver(solver, pomdp, updater=updater(pomdp))

# make sure internal function is type stable
planner = solve(solver, pomdp)
b = initial_state_distribution(pomdp)
B = POMCPOW.belief_type(POMCPOW.POWNodeFilter, typeof(pomdp))
tree = POMCPOWTree{B,Bool,Bool,typeof(b)}(b, 2*planner.solver.tree_queries)
@inferred POMCPOW.simulate(planner, POMCPOW.POWTreeObsNode(tree, 1), true, 10)
# @code_warntype POMCPOW.simulate(planner, POMCPOW.POWTreeObsNode(tree, 1), true, 10)

pomdp = LightDark1D()
solver = POMCPOWSolver(default_action=485)
planner = solve(solver, pomdp)

b = ParticleCollection([LightDark1DState(-1, 0)])
@test @inferred(action(planner, b)) == 485

b = initial_state_distribution(pomdp)
@inferred action(planner, b)

a, info = action_info(planner, b)
d3t = D3Tree(planner)
@test_throws KeyError d3t = D3Tree(info[:tree])

a, info = action_info(planner, b, tree_in_info=true)
d3t = D3Tree(planner)
d3t = D3Tree(info[:tree])
# inchrome(d3t)
