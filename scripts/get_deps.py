import sys
import os.path

path = sys.argv[1]

dirs = path.split("/")

deps = ""

for ind in range(len(dirs)):
    if dirs[ind] not in ['proof', 'note']:
        deps += '{}/{} '.format("/".join(dirs[0:ind + 1]), "defs.tex".format(dirs[ind]))

deps += "{}/ref.tex".format(path)
print(deps)