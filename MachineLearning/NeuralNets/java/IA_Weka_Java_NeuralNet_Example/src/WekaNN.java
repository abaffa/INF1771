import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;

import weka.classifiers.Evaluation;
import weka.classifiers.functions.MultilayerPerceptron;
import weka.core.Instances;
import weka.core.Utils;

public class WekaNN {

	public static BufferedReader readDataFile(String filename) {
		BufferedReader inputReader = null;
 
		try {
			inputReader = new BufferedReader(new FileReader(filename));
		} catch (FileNotFoundException ex) {
			System.err.println("File not found: " + filename);
		}
 
		return inputReader;
	}
 
	public static void main(String[] args) throws Exception {
		BufferedReader datafile = readDataFile("ads.txt");
 
		
		Instances data = new Instances(datafile);
		data.setClassIndex(data.numAttributes() - 1);
 	
		//Instance of NN
		MultilayerPerceptron mlp = new MultilayerPerceptron();

		//Setting Parameters
		//mlp.setLearningRate(0.1);
		//mlp.setMomentum(0.2);
		//mlp.setTrainingTime(2000);
		//mlp.setHiddenLayers("3");
		mlp.setOptions(Utils.splitOptions("-L 0.1 -M 0.2 -N 2000 -V 0 -S 0 -E 20 -H 3"));

		//Where,
		//L = Learning Rate
		//M = Momentum
		//N = Training Time or Epochs
		//H = Hidden Layers
		//etc.
		//Find all the parameter information
		//http://weka.sourceforge.net/doc.stable/weka/classifiers/functions/MultilayerPerceptron.html
			
		mlp.buildClassifier(data);
		//Saving Model
		//weka.core.SerializationHelper.write(<Stringth>, mlp);
		//Reading Model
		//MultilayerPerceptron mlp = (MultilayerPerceptron) weka.core.SerializationHelper.read(<Stringdel Path>);
		
		Evaluation eval = new Evaluation(data);
		eval.evaluateModel(mlp, data);

		System.out.println(eval.errorRate()); //Printing Training Mean root squared Error
		System.out.println(eval.toSummaryString()); //Summary of Training
				
	}
}
