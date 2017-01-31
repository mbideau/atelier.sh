# atelier.sh

Write and maintain clean shell scripts

'atelier' means 'workshop' in french language.

## Usage

atelier.sh should be aliased for a better user experience :
```
alias ws='atelier.sh'
```

```
atelier.sh ls 	List the available commands

atelier.sh [namespace:]command options arguments

where:
	namespace	the namespace of the command (i.e.: path)
	command		the command alias name to execute
	options		the command options (use --help)
	arguments	the command arguments (use --help)
```


## Commands


### Folders structure

Example:
```
<atelier.sh>
	commands
		<namespace1>
			command1.sh
			command2.sh
			...
		<namespace2>
			command1.sh
			command2.sh
			...
```
Namespace are just folder hierarchy.

