using POMCPOW
using Test

using POMDPs
using POMDPModels
using ParticleFilters
using POMDPTesting
using D3Trees
using BeliefUpdaters
using POMDPModelTools

@testset "all" begin
    solver = POMCPOWSolver()

    pomdp = BabyPOMDP()

    test_solver(solver, pomdp, updater=DiscreteUpdater(pomdp))
    test_solver(solver, pomdp)

    solver = POMCPOWSolver(max_time=0.1, tree_queries=typemax(Int))
    test_solver(solver, pomdp, updater=DiscreteUpdater(pomdp))

    @testset "type stability" begin
        # make sure internal function is type stable
        solver = POMCPOWSolver()
        planner = solve(solver, pomdp)
        b = initialstate_distribution(pomdp)
        B = POMCPOW.belief_type(POMCPOW.POWNodeFilter, typeof(pomdp))
        tree = POMCPOWTree{B,Bool,Bool,typeof(b)}(b, 2*planner.solver.tree_queries)
        @inferred POMCPOW.simulate(planner, POMCPOW.POWTreeObsNode(tree, 1), true, 10)
        # @code_warntype POMCPOW.simulate(planner, POMCPOW.POWTreeObsNode(tree, 1), true, 10)

        pomdp = LightDark1D()
        solver = POMCPOWSolver(default_action=485)
        planner = solve(solver, pomdp)

        b = ParticleCollection([LightDark1DState(-1, 0)])
        @test @test_logs (:warn,) @inferred(action(planner, b)) == 485

        b = initialstate_distribution(pomdp)
        @inferred action(planner, b)
    end;

    @testset "D3tree" begin
        # make sure internal function is type stable
        solver = POMCPOWSolver()
        planner = solve(solver, pomdp)
        b = initialstate_distribution(pomdp)
        a, info = action_info(planner, b)
        # d3t = D3Tree(planner)
        @test_throws KeyError d3t = D3Tree(info[:tree])

        a, info = action_info(planner, b, tree_in_info=true)
        # d3t = D3Tree(planner)
        d3t = D3Tree(info[:tree])
        # inchrome(d3t)
    end;

    @testset "init_node_sr_belief_error" begin
        include("init_node_sr_belief_error.jl")
    end;
end;
