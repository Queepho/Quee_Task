import sys
import matplotlib.pyplot as plt
import matplotlib as mpl
mpl.use('Agg')
from pymatgen.io.vasp.outputs import Vasprun
from pymatgen.electronic_structure.plotter import BSDOSPlotter,\
BSPlotter,BSPlotterProjected,DosPlotter

# read vasprun.xml，get band and dos information
bs_vasprun = Vasprun("./vasprun.xml",parse_projected_eigen=True)
bs_data = bs_vasprun.get_band_structure(line_mode=True)

# !the dos_data from /BS is not that much accurate!
dos_vasprun=Vasprun("./vasprun.xml")
dos_data=dos_vasprun.complete_dos

# set figure parameters, draw figure
banddos_fig = BSDOSPlotter(bs_projection='elements', dos_projection=None,
vb_energy_range=4, fixed_cb_energy=4)
banddos_fig.get_plot(bs=bs_data, dos=None)
plt.savefig('BS.png', dpi=int(sys.argv[1]))
