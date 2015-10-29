using SbsSW.SwiPlCs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IA_PrologExample
{
    class Program
    {
        static void Main(string[] args)
        {


            //Environment.SetEnvironmentVariable("SWI_HOME_DIR", @"c:\Program Files\swipl\");
            if (!PlEngine.IsInitialized)
            {
                //String[] param = { "-q" };  // suppressing informational and banner messages
                String[] param = { "-q", "-f", AppDomain.CurrentDomain.BaseDirectory + "ex_genitor.pl" };
                PlEngine.Initialize(param);

                PlQuery q1 = new PlQuery("ancestral(X, josé)");
                foreach (PlQueryVariables vars in q1.SolutionVariables)
                {
                    for (int i = 0; i < q1.VariableNames.Count; i++)
                    {
                        Console.Write(q1.VariableNames[i].ToString() + " -> " + (string)vars[q1.VariableNames[i]] + "\t");

                    }
                    Console.WriteLine();
                }
                PlEngine.PlCleanup();
            }

            Console.ReadLine();
        }
    }
}
