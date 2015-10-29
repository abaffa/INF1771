using Accord.MachineLearning.DecisionTrees;
using Accord.MachineLearning.DecisionTrees.Learning;
using Accord.MachineLearning.DecisionTrees.Rules;
using Accord.Statistics.Filters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IA_DecisionTree_Example
{
    public class DecisionTree_C45
    {

        Dictionary<String, List<String>> dic = new Dictionary<String, List<String>>();
        DataTable data = new DataTable();
        List<String> inputColumns = new List<String>();
        List<String> inputTypes = new List<String>();
        String outputColumn = "";

        public void ReadFile(String filename)
        {
            data.Clear();

            int counter = 0;
            string line;

            // Read the file and display it line by line.
            System.IO.StreamReader file =
                new System.IO.StreamReader(filename);
            while ((line = file.ReadLine()) != null)
            {

                if (counter == 0)
                {
                    inputColumns = line.Split(',').Select(p => p.Trim()).ToList();
                }
                else if (counter == 1)
                {
                    outputColumn = line.Trim();
                }
                if (counter == 2)
                {
                    inputTypes = line.Split(',').Select(p => p.Trim()).ToList();
                }
                else if (counter == 3)
                {

                    foreach (String c in line.Split(',').Select(p => p.Trim()).ToList()) {


                        Type tp = System.Type.GetType("System.String");
                        
                        if (inputTypes[data.Columns.Count] == "int")
                            tp = System.Type.GetType("System.Int32");
                        else if (inputTypes[data.Columns.Count] == "int")
                            tp = System.Type.GetType("System.Double");

                        data.Columns.Add(new DataColumn(c,tp));
                    }
                }
                else if (counter > 3)
                {
                    data.Rows.Add(line.Split(',').Select(p => p.Trim()).ToArray());
                }

                counter++;
            }

            file.Close();

            //System.Console.WriteLine("There were {0} lines.", counter);
        }

        public void CreateDic(String col, DataTable symbols)
        {
            List<String> n = new List<String>(from p in symbols.AsEnumerable()
                                              group p by p[col].ToString() into newGroup
                                              orderby newGroup.Key
                                              select newGroup.Key);


            dic.Remove(col);
            dic.Add(col, n);
        }

        public int GetIndex(String col, String value)
        {
            List<String> n = dic[col];

            for (int i = 0; i < n.Count; i++)
                if (n[i] == value)
                    return i;

            return -1;
        }

        public String GetValue(String col, int index)
        {
            List<String> n = dic[col];

            return n[index];
        }

        public int GetCount(String col)
        {
            List<String> n = dic[col];

            return n.Count;
        }


        double[] GetInputRow(DataRow p)
        {

            List<double> r = new List<double>();

            foreach (String s in inputColumns)
            {
                if (p[s].GetType() == System.Type.GetType("System.String"))
                    r.Add(GetIndex(s, p[s].ToString()));
                else if (p[s].GetType() == System.Type.GetType("System.Int32"))
                    r.Add((int)p[s]);
                else if (p[s].GetType() == System.Type.GetType("System.Double"))
                    r.Add((double)p[s]);
                    
            } 

            return r.ToArray();
        }

        DecisionVariable[] GetDecisionVariables()
        {
            {

                List<DecisionVariable> r = new List<DecisionVariable>();

                foreach (String s in inputColumns)
                    r.Add(new DecisionVariable(s, GetCount(s)));

                return r.ToArray();
            }
        }


        public void Run(String filename)
        {

            ReadFile(filename);

            // Now, we have to convert the textual, categorical data found
            // in the table to a more manageable discrete representation.
            // 
            // For this, we will create a codebook to translate text to
            // discrete integer symbols:
            // 
            Codification codebook = new Codification(data);

            // And then convert all data into symbols
            // 
            DataTable symbols = codebook.Apply(data);


            for (int i = 0; i < inputColumns.Count; i++)
                if (inputTypes[i] == "string") 
                CreateDic(inputColumns[i], symbols);
            
            CreateDic(outputColumn, symbols);

            double[][] inputs = (from p in symbols.AsEnumerable()
                              select GetInputRow(p)
                              ).Cast<double[]>().ToArray();


            int[] outputs = (from p in symbols.AsEnumerable()
                             select GetIndex(outputColumn, p[outputColumn].ToString())).Cast<int>().ToArray();

            // From now on, we can start creating the decision tree.
            // 
            var attributes = DecisionVariable.FromCodebook(codebook, inputColumns.ToArray());
            DecisionTree tree = new DecisionTree(attributes, 5); //outputClasses: 5


            // Now, let's create the C4.5 algorithm
            C45Learning c45 = new C45Learning(tree);

            // and learn a decision tree. The value of
            //   the error variable below should be 0.
            // 
            double error = c45.Run(inputs, outputs);


            // To compute a decision for one of the input points,
            //   such as the 25-th example in the set, we can use
            // 
            //int y = tree.Compute(inputs[25]);

            // Finally, we can also convert our tree to a native
            // function, improving efficiency considerably, with
            // 
            //Func<double[], int> func = tree.ToExpression().Compile();

            // Again, to compute a new decision, we can just use
            // 
            //int z = func(inputs[25]);

            var expression = tree.ToExpression();
            Console.WriteLine(tree.ToCode("ClassTest"));

            DecisionSet s = tree.ToRules();

            Console.WriteLine(s.ToString());

        }
    }
}
