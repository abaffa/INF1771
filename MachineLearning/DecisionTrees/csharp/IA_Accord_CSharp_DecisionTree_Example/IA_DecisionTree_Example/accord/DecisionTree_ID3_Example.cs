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
    public class DecisionTree_ID3_Example
    {
        Dictionary<String, List<String>> dic = new Dictionary<String, List<String>>();

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




        public void Run()
        {


            DataTable data = new DataTable("Mitchell's Tennis Example");

            data.Columns.Add("Day");
            data.Columns.Add("Outlook");
            data.Columns.Add("Temperature");
            data.Columns.Add("Humidity");
            data.Columns.Add("Wind");
            data.Columns.Add("PlayTennis");

            data.Rows.Add("D1", "Sunny", "Hot", "High", "Weak", "No");
            data.Rows.Add("D2", "Sunny", "Hot", "High", "Strong", "No");
            data.Rows.Add("D3", "Overcast", "Hot", "High", "Weak", "Yes");
            data.Rows.Add("D4", "Rain", "Mild", "High", "Weak", "Yes");
            data.Rows.Add("D5", "Rain", "Cool", "Normal", "Weak", "Yes");
            data.Rows.Add("D6", "Rain", "Cool", "Normal", "Strong", "No");
            data.Rows.Add("D7", "Overcast", "Cool", "Normal", "Strong", "Yes");
            data.Rows.Add("D8", "Sunny", "Mild", "High", "Weak", "No");
            data.Rows.Add("D9", "Sunny", "Cool", "Normal", "Weak", "Yes");
            data.Rows.Add("D10", "Rain", "Mild", "Normal", "Weak", "Yes");
            data.Rows.Add("D11", "Sunny", "Mild", "Normal", "Strong", "Yes");
            data.Rows.Add("D12", "Overcast", "Mild", "High", "Strong", "Yes");
            data.Rows.Add("D13", "Overcast", "Hot", "Normal", "Weak", "Yes");
            data.Rows.Add("D14", "Rain", "Mild", "High", "Strong", "No");

            // Create a new codification codebook to 
            // convert strings into integer symbols
            Codification codebook = new Codification(data, "Outlook", "Temperature", "Humidity", "Wind", "PlayTennis");

            // Translate our training data into integer symbols using our codebook:
            DataTable symbols = codebook.Apply(data);



            CreateDic("Outlook", symbols);
            CreateDic("Temperature", symbols);
            CreateDic("Humidity", symbols);
            CreateDic("Wind", symbols);
            CreateDic("PlayTennis", symbols);


            int[][] inputs = (from p in symbols.AsEnumerable()
                              select new int[]
                              {
                                  GetIndex("Outlook", p["Outlook"].ToString()),
                                  GetIndex("Temperature", p["Temperature"].ToString()),
                                  GetIndex("Humidity", p["Humidity"].ToString()),
                                  GetIndex("Wind", p["Wind"].ToString())
                              }).Cast<int[]>().ToArray();


            int[] outputs = (from p in symbols.AsEnumerable()
                             select GetIndex("PlayTennis", p["PlayTennis"].ToString())).Cast<int>().ToArray();




            /*
        // Gather information about decision variables
        DecisionVariable[] attributes =
{
  new DecisionVariable("Outlook",     3), // 3 possible values (Sunny, overcast, rain)
  new DecisionVariable("Temperature", 3), // 3 possible values (Hot, mild, cool)  
  new DecisionVariable("Humidity",    2), // 2 possible values (High, normal)    
  new DecisionVariable("Wind",        2)  // 2 possible values (Weak, strong) 
};

             */
            DecisionVariable[] attributes =
    {
      new DecisionVariable("Outlook",     GetCount("Outlook")), // 3 possible values (Sunny, overcast, rain)
      new DecisionVariable("Temperature", GetCount("Temperature")), // 3 possible values (Hot, mild, cool)  
      new DecisionVariable("Humidity",    GetCount("Humidity")), // 2 possible values (High, normal)    
      new DecisionVariable("Wind",        GetCount("Wind"))  // 2 possible values (Weak, strong) 
    };


            int classCount = GetCount("PlayTennis"); // 2 possible output values for playing tennis: yes or no

            //Create the decision tree using the attributes and classes
            DecisionTree tree = new DecisionTree(attributes, classCount);

            // Create a new instance of the ID3 algorithm
            ID3Learning id3learning = new ID3Learning(tree);

            // Learn the training instances!
            id3learning.Run(inputs, outputs);


            string answer = codebook.Translate("PlayTennis",
                tree.Compute(codebook.Translate("Sunny", "Hot", "High", "Strong")));

            Console.WriteLine("Calculate for: Sunny, Hot, High, Strong");
            Console.WriteLine("Answer: " + answer);


            var expression = tree.ToExpression();
            Console.WriteLine(tree.ToCode("ClassTest"));

            DecisionSet s = tree.ToRules();

            Console.WriteLine(s.ToString());

            // Compiles the expression to IL
            var func = expression.Compile();
        }
    }
}
