// This is a x64 example
// Using SWI-Prolog x64 version 6.1.1
// Augusto Baffa

#include <SWI-cpp.h>
#include <iostream>

using namespace std;

int main(){
	char* argv[] = { "swipl.dll", "-s", "teste.pl", NULL };
	_putenv("SWI_HOME_DIR=c:\\Program Files\\swipl");

	PlEngine e(3, argv);

	PlTermv av(2);
	av[1] = PlCompound("jose");
	PlQuery q("ancestral", av);

	while (q.next_solution())
	{
		cout << (char*)av[0] << endl;
	}

	cin.get();
	return 1;
}
