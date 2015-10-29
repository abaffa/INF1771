using AForge.Neuro;
using AForge.Neuro.Learning;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IA_Aforge_CSharp_NeuralNetworks
{
    class Program
    {
        static void Main(string[] args)
        {

            // initialize input and output values
            double[][] input = new double[4][] {
                new double[] {0, 0}, new double[] {0, 1},
                new double[] {1, 0}, new double[] {1, 1}
            };

            double[][] output = new double[4][] {
                new double[] {0}, new double[] {1},
                new double[] {1}, new double[] {0}
            };

            // create neural network
            ActivationNetwork network = new ActivationNetwork(
                new SigmoidFunction(1),
                2, // two inputs in the network
                2, // two neurons in the first layer
                1); // one neuron in the second layer
            // create teacher
            BackPropagationLearning teacher =
                new BackPropagationLearning(network);
            // loop
            for (int i = 0; i < 10000; i++)
            {
                // run epoch of learning procedure
                double error = teacher.RunEpoch(input, output);
                // check error value to see if we need to stop
                // ...
                Console.Out.WriteLine("#" + i + "\t" + error);
            }

            double[] ret1 = network.Compute(new double[] { 0, 0 });
            double[] ret2 = network.Compute(new double[] { 1, 0 });
            double[] ret3 = network.Compute(new double[] { 0, 1 });
            double[] ret4 = network.Compute(new double[] { 1, 1 });

            Console.Out.WriteLine();

            Console.Out.WriteLine("Eval(0, 0) = " + ret1[0]);
            Console.Out.WriteLine("Eval(1, 0) = " + ret2[0]);
            Console.Out.WriteLine("Eval(0, 1) = " + ret3[0]);
            Console.Out.WriteLine("Eval(1, 1) = " + ret4[0]);
            Console.ReadLine();

        }
    }
}
