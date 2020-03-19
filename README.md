# Pandemics_AgentBasedModel
Simulate viral disease spread (i.e. COVID-19) using an agent-based-model. In contrast to many existing ABM this one uses does not rely on randomly changing networks but instead combines up to three distinct either static or dynamic networks. Including some static networks is more realistic since many networks do not change quickly over time (i.e. families, social circles, school classes, etc.)

The simulation is written with NetLogo. If you want to execute the nlogo files you either need to download the Netlogo Software or load the nlogo file at https://netlogoweb.org/launch#Load.
Be aware that running the simulation with a reasonable number of agents in the web browser is very, very slow (not possible). The ABM-pandemics_web.nlogo file has a default low number of agents and runs in the browser but is also not very useful for simulating any real pandemics.
The SARS-CoV2.nlogo file uses a larger number of agents and reasonable values for the SARS-CoV2 virus and simulating the 2019-nCoV disease. It only runs reasonably on the desktop version.

You can contact me at achim.gerstenberg@ntnu.no

edit: and here is the "real deal", a publication about the spread of Covid19 with a professional simulation
https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf
