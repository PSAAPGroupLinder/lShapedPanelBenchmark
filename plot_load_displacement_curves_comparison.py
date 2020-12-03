import matplotlib.pyplot as plt
import numpy as np

# tex for pretty plots
plt.rcParams.update({
    "text.usetex": True,
    'text.latex.preamble':r'\usepackage{siunitx}'
    })

fig = plt.figure()
ax = fig.add_subplot(111)





# plot experimental results
data = np.loadtxt ( './experimental/Winkler_Abb-7.12_Versuchsreihe-A.csv' , delimiter=',' )

U = data[:,0]
RF = data[:,1] 

ax.scatter(U, RF, label='experimental results', marker='x', color='k')



# plot gradient_enhanced_rankine curves
files_gradient_enhanced_rankine = {'./gradient_enhanced_rankine/rankine_epsf=2e-3_ldam=2.csv' : r'ge rankine: $\epsilon_f=\num{2e-3}, l=\SI{2}{mm}$',
                                   './gradient_enhanced_rankine/rankine_epsf=4e-3_ldam=2.csv' : r'ge rankine: $\epsilon_f=\num{4e-3}, l=\SI{2}{mm}$',
                                   './gradient_enhanced_rankine/rankine_epsf=8e-3_ldam=2.csv' : r'ge rankine: $\epsilon_f=\num{8e-3}, l=\SI{2}{mm}$',
                                   './gradient_enhanced_rankine/rankine_epsf=2e-3_ldam=4.csv' : r'ge rankine: $\epsilon_f=\num{2e-3}, l=\SI{4}{mm}$',
                                   './gradient_enhanced_rankine/rankine_epsf=4e-3_ldam=4.csv' : r'ge rankine: $\epsilon_f=\num{4e-3}, l=\SI{4}{mm}$',
                                   './gradient_enhanced_rankine/rankine_epsf=8e-3_ldam=4.csv' : r'ge rankine: $\epsilon_f=\num{8e-3}, l=\SI{4}{mm}$',}
colors_rankine = plt.cm.Blues_r(np.linspace(0.0, .8, 6 ))

for color , (f, lab) in zip (colors_rankine, files_gradient_enhanced_rankine.items() ):
    
    data = np.loadtxt ( f, delimiter=',', skiprows=1)

    U = data[:,0]
    RF = data[:,1] * -10 # factor to scale model results from 10mm up to 100mm

    ax.plot(U, RF, label=lab, c = color)
# end plot gradient_enhanced_rankine curves


# plot the efem results
files_efem = {'./embedded_fem/efem_very_coarse_paper.csv' : r'efem-very-coarse-paper',
	      './embedded_fem/efem_coarse_paper.csv' : r'efem-coarse-paper',
	      './embedded_fem/efem_fine.csv' : r'efem-fine (Matthias mesh)',
	      './embedded_fem/efem_coarse.csv' : r'efem-coarse (Matthias mesh)',}

colors_efem = plt.cm.Reds_r(np.linspace(0.0, 0.6, 4 ))

for color , (f, lab) in zip(colors_efem, files_efem.items()):
    
    data = np.loadtxt ( f, delimiter=' ', skiprows=0)

    U = data[:,0]
    RF = data[:,1]

    ax.plot(U, RF, label=lab, c = color, linestyle = '--')
# end plot gradient_enhanced_rankine curves



# make plots readable
ax.set_xlabel('displacement (mm)')
ax.set_ylabel('reaction force (N)')
ax.grid(True)
fig.legend()

fig.savefig('load_displacement_curves_comparison.png')

plt.show()
