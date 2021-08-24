using Plots: length
using Plots,DifferentialEquations,Measures

############################################### CSTR FUNCTION #################################################################
function cstr(du,u,p,t)

    Ca,T = u # States
    Ea,k₀,V,ρ,Cₚ,ΔH,UA,q,Caf,Tf,Tc = p # Parameters
    k(x) = k₀*exp(-Ea/8.314/x) # kinetic constant

    du[1]  = dCa = (q/V)*(Caf-Ca) - k(T)*Ca # derivatie of Ca
    du[2]  = dT = (q/V)*(Tf-T) + (-ΔH/ρ/Cₚ)*k(T)*Ca + (UA/V/ρ/Cₚ)*(Tc-T) # Derivative of T

end
##############################################################################################################################

############################################### PARAMETERS ###################################################################
Ea = 72750          # activation energy J/gmol
k₀ = 7.2e10         # Arrhenius rate constant 1/min
V = 100.0           # Volume [L]
ρ = 1000.0          # Density [g/L]
Cₚ = 0.239          # Heat capacity [J/g/K]
ΔH = -5.0e4         # Enthalpy of reaction [J/mol]
UA = 5.0e4          # Heat transfer [J/min/K]
q = 100.0           # Flowrate [L/min]
Caf = 1.0           # Inlet feed concentration [mol/L]
Tf = 350.0          # Inlet feed temperature [K]
Tc = 280.0          # Coolant temperature [K]
##############################################################################################################################

############################################### INITIAL COND #################################################################
Ca0 = 0.5
T0 = 350.0
##############################################################################################################################

############################################### SIMULATION ###################################################################
u0 = [Ca0 , T0] # Initial Condition Array
p = [Ea,k₀,V,ρ,Cₚ,ΔH,UA,q,Caf,Tf,Tc] # Parameters Array
tspan = (0.0 , 10.0) # Creating time span to solve the ODE from 0 to 10 min
prob = ODEProblem(cstr,u0,tspan,p) # Creating the ODEProblem
sol = solve(prob,Tsit5(),saveat=0.1) # Solving the problem and saving the results at each 0.1 min
##############################################################################################################################

############################################### PLOTTING SOLUTION ###############################################################
gr(size=(800,450)) # Backend choice
t = 0:0.1:10 # Time array
T_react = sol[2,:] # Getting Temperature solution vector
Ca_react = sol[1,:] # Getting Concentration solution vector
p_Ca = plot(t,Ca_react,title="Reactor's Concentration",ylabel="Ca (mol/L)",
            label=""); # Creating a plot to Concentration
            
p_T = plot(t,T_react,title="Reactor's Temperature",ylabel="Temperature (K)",
            xlabel="Time (min)",label=""); # Creating a plot to Temperature

transient_plot = plot(p_Ca,p_T,layout=(2,1)) # Adding both plots to a grid layout of 2 rows and 1 column
savefig(transient_plot,"Images/transient_plot.png") # Saving the transient_plot

phase_plot = plot(sol,vars=(1,2),ylabel="Temperature (K)",xlabel="Concentration (mol/L)",
                    title="Phase Space",label="") # Creating a plot from the States (Ca,T) a.k.a Phase Plot
savefig(phase_plot,"Images/phase_plot.png") # Saving the phase_plot

sub = plot(p_Ca,p_T,phase_plot,layout=@layout([[a;b] c]),left_margin=5mm)
savefig(sub,"Images/all_in_one.png") # Saving all plots in one
##############################################################################################################################

############################################### ANIMATION PLOT ###############################################################
# This function simulates the CSTR for a giving Coolant Temerature.
function sim_cstr(Tc)
    u0 = [Ca0 , T0] # Initial Condition Array
    p = [Ea,k₀,V,ρ,Cₚ,ΔH,UA,q,Caf,Tf,Tc] # Parameters Array
    tspan = (0.0 , 10.0) # Creating time span to solve the ODE from 0 to 10 min
    prob = ODEProblem(cstr,u0,tspan,p) # Creating the ODEProblem
    sol = solve(prob,Tsit5(),saveat=0.1) # Solving the problem and saving the results at each 0.1 min
    return sol
end

Tcs = 280:0.5:350 # Array of Coolant Temperatures 
sols = sim_cstr.(Tcs); # Solving for each Coolant Temperature in Tcs

# Creating animation using the animate macro
anim = @animate for i ∈ 1:length(Tcs)
    # Plots each solution in the sols array (these makes a new plot for each solution, thus older solutions don't appear)
    plot(
        plot(sols[i].t,sols[i][1,:],title="Reactor's Concentration (Tc = "*string(Tcs[i])*"K)",ylabel="Ca (mol/L)",label=:none),
        plot(sols[i].t,sols[i][2,:],title="Reactor's Temperature (Tc = "*string(Tcs[i])*"K)",ylabel="Temperature (K)",xlabel="Time (min)",label=:none),
        plot(sols[i],vars=(1,2),ylabel="Temperature (K)",xlabel="Concentration (mol/L)",title="Phase Space (Tc = "*string(Tcs[i])*"K)",label=:none),
        layout=@layout([[a;b] c]),left_margin=10mm
    )
    scatter!((Ca0,T0),sp=3,label="Initial Condition",markercolor=:black) # Adds a point in the phase plot regarding the initial condition
end
gif(anim, "Images/cstr_coolant_effect.gif", fps = 10) # create a gif using the anim variable where we've stored our frames
##############################################################################################################################

function derivatives_cstr(Ca,T,Tc)

    k(x) = k₀*exp(-Ea/8.314/x) # kinetic constant

    dCa = (q/V)*(Caf-Ca) - k(T)*Ca # derivatie of Ca
    dT = (q/V)*(Tf-T) + (-ΔH/ρ/Cₚ)*k(T)*Ca + (UA/V/ρ/Cₚ)*(Tc-T) # Derivative of T

    return [dCa,dT]

end

meshgrid(x,y) = (repeat(x, outer=length(y)),repeat(y, inner=length(x)))
Ca_test,T_test = meshgrid(0:0.1:1,280:10:350)
dv = derivatives_cstr.(Ca_test,T_test,305)
dca,dt = hcat(dv...)'[:,1],hcat(dv...)'[:,2]
scale = 1
dca,dt = dca./sqrt.(dca.^2+dt.^2),dt./sqrt.(dca.^2+dt.^2)
quiver(Ca_test,T_test,quiver=scale.*(dca,dt),color=:inferno)
scatter!([Ca0],[T0])
