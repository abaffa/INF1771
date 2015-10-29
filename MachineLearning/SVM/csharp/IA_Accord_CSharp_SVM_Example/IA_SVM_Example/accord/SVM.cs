using Accord.MachineLearning;
using Accord.MachineLearning.VectorMachines;
using Accord.MachineLearning.VectorMachines.Learning;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IA_DecisionTree_Example.accord
{
    public class SVM
    {
        public void Run()
        {
            // Example AND problem
            double[][] inputs =
{
    new double[] { 0, 0 }, // 0 and 0: 0 (label -1)
    new double[] { 0, 1 }, // 0 and 1: 0 (label -1)
    new double[] { 1, 0 }, // 1 and 0: 0 (label -1)
    new double[] { 1, 1 }  // 1 and 1: 1 (label +1)
};

            // Dichotomy SVM outputs should be given as [-1;+1]
            int[] labels =
{
    // 0,  0,  0, 1
      -1, -1, -1, 1
};

            // Create a Support Vector Machine for the given inputs
            SupportVectorMachine machine = new SupportVectorMachine(inputs[0].Length);

            // Instantiate a new learning algorithm for SVMs
            SequentialMinimalOptimization smo = new SequentialMinimalOptimization(machine, inputs, labels);

            // Set up the learning algorithm
            smo.Complexity = 1.0;

            // Run the learning algorithm
            double error = smo.Run();

            // Compute the decision output for one of the input vectors
            int decision = System.Math.Sign(machine.Compute(inputs[0]));
        }
    }
}
