using Accord.Statistics.Filters;
using Accord.MachineLearning.DecisionTrees.Learning;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Accord.MachineLearning.DecisionTrees;
using System.Data;
using Accord.MachineLearning.DecisionTrees.Rules;

namespace IA_DecisionTree_Example
{
    public class DecisionTree_ID3_Dynamic
    {

        Dictionary<String, List<String>> dic = new Dictionary<String, List<String>>();
        DataTable data = new DataTable();
        List<String> inputColumns = new List<String>();
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
                else if (counter == 3)
                {
                    foreach (String c in line.Split(',').Select(p => p.Trim()).ToList())
                        data.Columns.Add(c);
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


        int[] GetInputRow(DataRow p)
        {

            List<int> r = new List<int>();

            foreach (String s in inputColumns)
                r.Add(GetIndex(s, p[s].ToString()));

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

            // Create a new codification codebook to 
            // convert strings into integer symbols


            Codification codebook = new Codification(data, inputColumns.ToArray());

            // Translate our training data into integer symbols using our codebook:
            DataTable symbols = codebook.Apply(data);


            foreach (String s in inputColumns)
                CreateDic(s, symbols);

            CreateDic(outputColumn, symbols);


            int[][] inputs = (from p in symbols.AsEnumerable()
                              select GetInputRow(p)
                              ).Cast<int[]>().ToArray();


            int[] outputs = (from p in symbols.AsEnumerable()
                             select GetIndex(outputColumn, p[outputColumn].ToString())).Cast<int>().ToArray();


            // Gather information about decision variables

            DecisionVariable[] attributes = GetDecisionVariables();


            int classCount = GetCount(outputColumn); // 2 possible output values for playing tennis: yes or no

            //Create the decision tree using the attributes and classes
            DecisionTree tree = new DecisionTree(attributes, classCount);

            // Create a new instance of the ID3 algorithm
            ID3Learning id3learning = new ID3Learning(tree);
            //C45Learning c45learning = new C45Learning(tree);

            // Learn the training instances!
            id3learning.Run(inputs, outputs);
            //c45learning.Run(inputs2, outputs);

            /*
            string answer = codebook.Translate(outputColumn,
                tree.Compute(codebook.Translate("Sunny", "Hot", "High", "Strong")));

            Console.WriteLine("Calculate for: Sunny, Hot, High, Strong");
            Console.WriteLine("Answer: " + answer);
            */

            var expression = tree.ToExpression();
            Console.WriteLine(tree.ToCode("ClassTest"));

            DecisionSet rules = tree.ToRules();

            Console.WriteLine(rules.ToString());

            // Compiles the expression to IL
            var func = expression.Compile();
        }
    }
}

