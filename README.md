# RansomwareSimulator

## Introduction
The Ransomware Simulator is a simple compartmental model extending the SIR (Susceptible, Infected, Recovered) model used in Epidemiology to study disease patterns.

The simulator uses the following compartments Susceptible, Infected, Encrypted, and Recovered (SIER). 

Unlike traditional infections and the models used to study them, Ransomware Infections have at least 2 distinct phases, an infected & encryption phase, and a separate recovery phase, which occurs some time after the infection has stopped. Due to this pattern, the ransomware simulator is implemented in two phases, a simulation of infection & encryption, and a recovery phase implemented as a resiliency curve.

The Ransomware Simulator also allows a user to easily simulate recovery improvements. To do this the recovery phase is split in to two sub phases: forensics and restoration.

During the foresnics phase, no recovery work is undertaken, it is an investigatory phase in which an incident response time identifies the point of infection and the time of infection to provide the recovery team with a point to which it is safe to restore the IT estate.

The restoration phase plots the recovery of compute on to an S-curve, specifically a Gompertz curve: slow to ramp up, fast in the middle, and slowing to a crawl at the very end.

Different improvement techniques can be supplied to the simulation as post ante improvements.

## How to Use

### Get Ransomware Simulator


### Create Configuration
The simulation needs three sets of information to run:
- A set of simulation parameters:
- A description of the servers / PC's within the target environment

The easiest way to create the config is using a yaml file. To create a configuration template:
```julia
using RansomwareSimulator
generate_config()
```

#### Add all Servers and PC's
Once the config file is generated, go ahead and add your servers / PC's to the servers list. A note of caution when filling the susceptible boolean.
Teams often underestimate their vulnerability.

#### Consider the weakest link
Although this simulator is simple it does allow you to simulate many different attacks: maybe all the Windows machines are vulnerable, maybe only Windows 2016, or only RHEL 7.x. Where this view falls down is where teams have already deployed micro-segmentation, unfortunately this simulation is not complex enough to model network graphs (A future graph based simulator is planned to over come this) in a segmeneted network, view the suscetibility in terms of the weakest link. 

Consider a scenario where all Windows machines are vulnerable to an exploit and you want to model this. When you investigate the network you find that all applications are in their own segments. Movement between applications is not possible. In this environment many teams only consider the handful of machines that make up a single application as susceptible. 

You continue to dig in to the network, and you realise that you have a Active Directory machines that are vulnerable, and communicate with all other windows systems. When you view the network from the point of view of the AD server there are many more susceptible machines.

#### Add any post ante improvements
If you are using the simulation to test possible improvements in recovery time, add these to the `post_ante` section.
The config template contains three examples that should be removed, or updated.


### Run Simulation
Once the configuartion file is completed, its time to go ahead and run the simulation. To do this we need to read the config file and pass its contents to the `run_simulation()` function.

The following code is enough to get started:

```julia
import YAML
import Plots
using RansomwareSimulator

config = YAML.load_file(<path to config file>)
parameters, state = run_simulation(config)
```

### Generate output

Now the infection & encryption simulation is complete, it's time to generate the output charts, the following code snippet will generate the first set of charts, detailing the time of infection, the time of complete encryption, and the GB's encrypted over time:

```juila
infection = infection_plot(state)
encrypted = encrypted_plot(state)
encrypted_gb = encrypted_gb_plot(state)
display(infection)
display(encrypted)
display(encrypted_gb)
```

Next we need to generate the recovery plot. If you did not specify any post ante improvements use:

```julia
recoveries = function_loss_plot(state, parameters)
for recovery in recoveries
    display(recovery)
end
```

if you did specify one or more post ante improvements use:

```julia
recoveries = function_loss_plot(state, parameters, true)
for recovery in recoveries
    display(recovery)
end
```
## Example output
As an example of using Ransomware Simulator. An imaginary server estate of 100 servers was created. Of the 100 servers 88 are susceptiable, and 12 are not susceptible.

3 post ante improvements were simulated:
- a 200% improvement in restoration time
- a 20% improvement in both forensics and restoration
- a 200% improvement in forensics

The simulation perameters were left at their default values.

### Infection Plot
![Infection plot](/docs/img/example_infected_plot.png)
### Encrypted Plot
![Encrypted plot](/docs/img/example_infected_plot.png)
### Encrypted GB plot
![Encrypted GB Plot](/docs/img/example_infected_gb_plot.png)
### Recovery Curve
![Recovery Curve](/docs/img/example_recovery_curve.png)
### Post Ante Recovery Curves
![post ante recovery curve 1](/docs/img/example_recovery_curve_restore.png)
![post ante recovery curve 2](/docs/img/example_recovery_curve_forensics.png)
![post ante recovery curve 3](/docs/img/example_recovery_curve_both.png)
![post ante recovery curve 4](/docs/img/example_recovery_curve_combined.png))
