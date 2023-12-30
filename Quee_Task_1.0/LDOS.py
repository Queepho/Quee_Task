import sys
import matplotlib.pyplot as plt
from pymatgen.electronic_structure.core import OrbitalType
from pymatgen.electronic_structure.plotter import DosPlotter
from pymatgen.io.vasp.outputs import Vasprun

#load data
result = Vasprun('./vasprun.xml', parse_potcar_file=False)
complete_dos = result.complete_dos

def split_lines(multi_str):
	return multi_str.split('\n')

def split_space(multi_str):
	return multi_str.split(' ')

def IsNull(multi_str):
	SplitedLine = split_lines(multi_str)

	Result = []

	index = 1
	while (index < len(SplitedLine)):
		temp = split_space(SplitedLine[index])
		Result.append(temp[1])

		index += 1

	Apoint = []
	index = 0
	while (index < len(Result)):
		if (f"{Result[index]}" == "0.00000"):
			pass
		else:
			Apoint.append(Result[index])

		index += 1

	if (len(Apoint) == 0):
		return 1
	else:
		return 0








max = len(complete_dos.structure.species)
index = 0
strs = ''
Lis_elm = []
Lis_num = []
while (index < max):
	if (complete_dos.structure.species[index] in Lis_elm):
		pass
	else:
		Lis_num.append(index)
		Lis_elm.append(complete_dos.structure.species[index])
		temp = f'{complete_dos.structure.species[index]}'
		strs = strs + temp
	index += 1

plotter = DosPlotter()
plotter.add_dos('Total DOS', result.tdos)

max = len(Lis_elm)
index = 0

print(strs)

while (index < max):
	Ldos = complete_dos.get_element_spd_dos(Lis_elm[index])
	if (IsNull(f"""{Ldos[OrbitalType.d]}""")):
		print(f"{Lis_elm[index]}-d IsNull")
		pass
	else:
		print(f"{Lis_elm[index]}-d NotNull")
		plotter.add_dos(f"{complete_dos.structure.species[Lis_num[index]]}(d)", Ldos[OrbitalType.d])
	if (IsNull(f"""{Ldos[OrbitalType.p]}""")):
		print(f"{Lis_elm[index]}-p IsNull")
		pass
	else:
		print(f"{Lis_elm[index]}-p NotNull")
		plotter.add_dos(f"{complete_dos.structure.species[Lis_num[index]]}(p)", Ldos[OrbitalType.p])
	if (IsNull(f"""{Ldos[OrbitalType.s]}""")):
		print(f"{Lis_elm[index]}-s IsNull")
		pass
	else:
		print(f"{Lis_elm[index]}-s NotNull")
		plotter.add_dos(f"{complete_dos.structure.species[Lis_num[index]]}(s)", Ldos[OrbitalType.s])

	index += 1




plotter.get_plot(xlim=(int(sys.argv[2]),int(sys.argv[3])), ylim=(int(sys.argv[4]),int(sys.argv[5])))
plt.savefig(f"{strs}_LDOS.png", dpi=int(sys.argv[1]))




