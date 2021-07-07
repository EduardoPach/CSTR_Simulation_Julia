using Plots,DifferentialEquations

########################### CSTR MODEL #############################
function cstr(du,u,p,t)

    Ca,T = u # States
    Ea,k₀,V,ρ,Cₚ,ΔH,UA,q,Caf,Tf,Tc = p # Parameters
    k(x) = k₀*exp(-Ea/8.314/x) # kinetic constant

    du[1] = dCa = (q/V)*(Caf-Ca) - k(T)*Ca # derivatie of Ca
    du[2]  = dT = (q/V)*(Tf-T) + (-ΔH/ρ/Cₚ)*k(T)*Ca + (UA/V/ρ/Cₚ)*(Tc-T) # Derivative of T

end
####################################################################

########################### PARAMETERS #############################
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
Tc = 300.0          # Coolant temperature [K]
####################################################################

########################### INITIAL COND ###########################
Ca0 = 0.5
T0 = 350.0
####################################################################

########################### SIMULATION #############################
u0 = [Ca0 , T0]
p = [Ea,k₀,V,ρ,Cₚ,ΔH,UA,q,Caf,Tf,Tc]
tspan = (0.0 , 10.0)
prob = ODEProblem(cstr,u0,tspan,p)
sol = solve(prob,Tsit5(),saveat=0.1)
####################################################################

########################### PLOTTING SOLUTION #############################
gr()
t = 0:0.1:10
T_react = sol[2,:]
Ca_react = sol[1,:]
p_Ca = plot(t,Ca_react,title="Reactor's Concentration over Time",ylabel="Ca (mol/L)",
            color=:red,label="");
            
p_T = plot(t,T_react,title="Reactor's Temperature over Time",ylabel="Temperature (K)",
            xlabel="Time (min)",color=:orange,label="");

transient_plot = plot(p_Ca,p_T,layout=(2,1))
savefig(transient_plot,"Images/transient_plot.png")

phase_plot = plot(sol,vars=(1,2),ylabel="Temperature (K)",xlabel="Concentration (mol/L)",
                    title="Phase Space",label="")
savefig(phase_plot,"Images/phase_plot.png")
