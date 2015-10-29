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
using System.IO;
using System.Threading;

namespace IA_DecisionTree_Example
{
    class Program
    {
        static void Main(string[] args)
        {
            //DecisionTree_ID3_Example t = new DecisionTree_ID3_Example();
            //t.Run();

            //DecisionTree_ID3_Dynamic t = new DecisionTree_ID3_Dynamic();
            //t.Run("PlayTennis.txt");
            //t.Run("EsperaRestaurante.txt");
            //t.Run("weather.txt");

            DecisionTree_C45 t = new DecisionTree_C45();
            t.Run("weather.txt");
            //t.Run("nursery.txt");

            //Algoritmo Programado sem Biblioteca
            //DecisionTree_ID3 id3 = new DecisionTree_ID3();
            //id3.Run();

            // Suspend the screen.
            System.Console.ReadLine();
        }
    }
}
