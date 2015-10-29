using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IA_DecisionTree_Example
{
	/// <summary>
	/// Classe que implementa uma árvore de Decisão usando o algoritmo ID3
	/// </summary>
	public class DecisionTreeID3
	{
		private DataTable mSamples;
		private int mTotalPositives = 0;
		private int mTotal = 0;
		private string mTargetAttribute = "result";
		private double mEntropySet = 0.0;

		/// <summary>
		/// Retorna o total de amostras positivas em uma tabela de amostras
		/// </summary>
		/// <param name="samples">DataTable com as amostras</param>
		/// <returns>O nro total de amostras positivas</returns>
		private int countTotalPositives(DataTable samples)
		{
			int result = 0;

			foreach (DataRow aRow in samples.Rows)
			{
				if ((bool)aRow[mTargetAttribute] == true)
					result++;
			}

			return result;
		}

		/// <summary>
		/// Calcula a entropia dada a seguinte fórmula
		/// -p+log2p+ - p-log2p-
		/// 
		/// onde: p+ é a proporção de valores positivos
		///		  p- é a proporção de valores negativos
		/// </summary>
		/// <param name="positives">Quantidade de valores positivos</param>
		/// <param name="negatives">Quantidade de valores negativos</param>
		/// <returns>Retorna o valor da Entropia</returns>
		private double calcEntropy(int positives, int negatives)
		{
			int total = positives + negatives;
			double ratioPositive = (double)positives/total;
			double ratioNegative = (double)negatives/total;

			if (ratioPositive != 0)
				ratioPositive = -(ratioPositive) * System.Math.Log(ratioPositive, 2);
			if (ratioNegative != 0)
				ratioNegative = - (ratioNegative) * System.Math.Log(ratioNegative, 2);

			double result =  ratioPositive + ratioNegative;

			return result;
		}

		/// <summary>
		/// Varre tabela de amostras verificando um atributo e se o resultado é positivo ou negativo
		/// </summary>
		/// <param name="samples">DataTable com as amostras</param>
		/// <param name="attribute">Atributo a ser pesquisado</param>
		/// <param name="value">valor permitido para o atributo</param>
		/// <param name="positives">Conterá o nro de todos os atributos com o valor determinado com resultado positivo</param>
		/// <param name="negatives">Conterá o nro de todos os atributos com o valor determinado com resultado negativo</param>
		private void getValuesToAttribute(DataTable samples, Attribute attribute, string value, out int positives, out int negatives)
		{
			positives = 0;
			negatives = 0;

			foreach (DataRow aRow in samples.Rows)
			{
				if (  ((string)aRow[attribute.AttributeName] == value) )
					if ( (bool)aRow[mTargetAttribute] == true) 
						positives++;
					else
						negatives++;
			}		
		}

		/// <summary>
		/// Calcula o ganho de um atributo
		/// </summary>
		/// <param name="attribute">Atributo a ser calculado</param>
		/// <returns>O ganho do atributo</returns>
		private double gain(DataTable samples, Attribute attribute)
		{
			string[] values = attribute.values;
			double sum = 0.0;

			for (int i = 0; i < values.Length; i++)
			{
				int positives, negatives;
				
				positives = negatives = 0;
				
				getValuesToAttribute(samples, attribute, values[i], out positives, out negatives);
				
				double entropy = calcEntropy(positives, negatives);				
				sum += -(double)(positives + negatives)/mTotal * entropy;
			}
			return mEntropySet + sum;
		}

		/// <summary>
		/// Retorna o melhor atributo.
		/// </summary>
		/// <param name="attributes">Um vetor com os atributos</param>
		/// <returns>Retorna o que tiver maior ganho</returns>
		private Attribute getBestAttribute(DataTable samples, Attribute[] attributes)
		{
			double maxGain = 0.0;
			Attribute result = null;

			foreach (Attribute attribute in attributes)
			{
				double aux = gain(samples, attribute);
				if (aux > maxGain)
				{
					maxGain = aux;
					result = attribute;
				}
			}
			return result;
		}

		/// <summary>
		/// Retorna true caso todos os exemplos da amostragem são positivos
		/// </summary>
		/// <param name="samples">DataTable com as amostras</param>
		/// <param name="targetAttribute">Atributo (coluna) da tabela a qual será verificado</param>
		/// <returns>True caso todos os exemplos da amostragem são positivos</returns>
		private bool allSamplesPositives(DataTable samples, string targetAttribute)
		{			
			foreach (DataRow row in samples.Rows)
			{
				if ( (bool)row[targetAttribute] == false)
					return false;
			}

			return true;
		}

		/// <summary>
		/// Retorna true caso todos os exemplos da amostragem são negativos
		/// </summary>
		/// <param name="samples">DataTable com as amostras</param>
		/// <param name="targetAttribute">Atributo (coluna) da tabela a qual será verificado</param>
		/// <returns>True caso todos os exemplos da amostragem são negativos</returns>
		private bool allSamplesNegatives(DataTable samples, string targetAttribute)
		{
			foreach (DataRow row in samples.Rows)
			{
				if ( (bool)row[targetAttribute] == true)
					return false;
			}

			return true;			
		}

        /// <summary>
        /// Retorna uma lista com todos os valores distintos de uma tabela de amostragem
        /// </summary>
        /// <param name="samples">DataTable com as amostras</param>
        /// <param name="targetAttribute">Atributo (coluna) da tabela a qual será verificado</param>
        /// <returns>Um ArrayList com os valores distintos</returns>
		private ArrayList getDistinctValues(DataTable samples, string targetAttribute)
		{
			ArrayList distinctValues = new ArrayList(samples.Rows.Count);

			foreach(DataRow row in samples.Rows)
			{
				if (distinctValues.IndexOf(row[targetAttribute]) == -1)
					distinctValues.Add(row[targetAttribute]);
			}

			return distinctValues;
		}

		/// <summary>
		/// Retorna o valor mais comum dentro de uma amostragem
		/// </summary>
		/// <param name="samples">DataTable com as amostras</param>
		/// <param name="targetAttribute">Atributo (coluna) da tabela a qual será verificado</param>
		/// <returns>Retorna o objeto com maior incidência dentro da tabela de amostras</returns>
		private object getMostCommonValue(DataTable samples, string targetAttribute)
		{
			ArrayList distinctValues = getDistinctValues(samples, targetAttribute);
			int[] count = new int[distinctValues.Count];

			foreach(DataRow row in samples.Rows)
			{
				int index = distinctValues.IndexOf(row[targetAttribute]);
				count[index]++;
			}
			
			int MaxIndex = 0;
			int MaxCount = 0;

			for (int i = 0; i < count.Length; i++)
			{
				if (count[i] > MaxCount)
				{
					MaxCount = count[i];
					MaxIndex = i;
				}
			}

			return distinctValues[MaxIndex];
		}

		/// <summary>
		/// Monta uma árvore de decisão baseado nas amostragens apresentadas
		/// </summary>
		/// <param name="samples">Tabela com as amostragens que serão apresentadas para a montagem da árvore</param>
		/// <param name="targetAttribute">Nome da coluna da tabela que possue o valor true ou false para 
		/// validar ou não uma amostragem</param>
		/// <returns>A raiz da árvore de decisão montada</returns></returns?>
		private TreeNode internalMountTree(DataTable samples, string targetAttribute, Attribute[] attributes)
		{
			if (allSamplesPositives(samples, targetAttribute) == true)
				return new TreeNode(new Attribute(true));
			
			if (allSamplesNegatives(samples, targetAttribute) == true)
				return new TreeNode(new Attribute(false));

			if (attributes.Length == 0)
				return new TreeNode(new Attribute(getMostCommonValue(samples, targetAttribute)));			
		
			mTotal = samples.Rows.Count;
			mTargetAttribute = targetAttribute;
			mTotalPositives = countTotalPositives(samples);

			mEntropySet = calcEntropy(mTotalPositives, mTotal - mTotalPositives);
			
			Attribute bestAttribute = getBestAttribute(samples, attributes); 

			TreeNode root = new TreeNode(bestAttribute);
			
			DataTable aSample = samples.Clone();			
			
			foreach(string value in bestAttribute.values)
			{				
				// Seleciona todas os elementos com o valor deste atributo				
				aSample.Rows.Clear();

				DataRow[] rows = samples.Select(bestAttribute.AttributeName + " = " + "'"  + value + "'");
			
				foreach(DataRow row in rows)
				{					
					aSample.Rows.Add(row.ItemArray);
				}				
				// Seleciona todas os elementos com o valor deste atributo				

				// Cria uma nova lista de atributos menos o atributo corrente que é o melhor atributo				
				ArrayList aAttributes = new ArrayList(attributes.Length - 1);
				for(int i = 0; i < attributes.Length; i++)
				{
					if (attributes[i].AttributeName != bestAttribute.AttributeName)
						aAttributes.Add(attributes[i]);
				}
				// Cria uma nova lista de atributos menos o atributo corrente que é o melhor atributo

				if (aSample.Rows.Count == 0)
				{
					return new TreeNode(new Attribute(getMostCommonValue(aSample, targetAttribute)));
				}
				else
				{				
					DecisionTreeID3 dc3 = new DecisionTreeID3();
					TreeNode ChildNode =  dc3.mountTree(aSample, targetAttribute, (Attribute[])aAttributes.ToArray(typeof(Attribute)));
					root.AddTreeNode(ChildNode, value);
				}
			}

			return root;
		}


		/// <summary>
		/// Monta uma árvore de decisão baseado nas amostragens apresentadas
		/// </summary>
		/// <param name="samples">Tabela com as amostragens que serão apresentadas para a montagem da árvore</param>
		/// <param name="targetAttribute">Nome da coluna da tabela que possue o valor true ou false para 
		/// validar ou não uma amostragem</param>
		/// <returns>A raiz da árvore de decisão montada</returns></returns?>
		public TreeNode mountTree(DataTable samples, string targetAttribute, Attribute[] attributes)
		{
			mSamples = samples;
			return internalMountTree(mSamples, targetAttribute, attributes);
		}
	}



    public class DecisionTree_ID3
    {


        public void printNode(TreeNode root, string tabs)
        {
            Console.WriteLine(tabs + '|' + root.attribute + '|');

            if (root.attribute.values != null)
            {
                for (int i = 0; i < root.attribute.values.Length; i++)
                {
                    Console.WriteLine(tabs + "\t" + "<" + root.attribute.values[i] + ">");
                    TreeNode childNode = root.getChildByBranchName(root.attribute.values[i]);
                    printNode(childNode, "\t" + tabs);
                }
            }
        }


        DataTable getDataTable()
        {
            DataTable result = new DataTable("samples");
            DataColumn column = result.Columns.Add("ceu");
            column.DataType = typeof(string);

            column = result.Columns.Add("temperatura");
            column.DataType = typeof(string);

            column = result.Columns.Add("humidade");
            column.DataType = typeof(string);

            column = result.Columns.Add("vento");
            column.DataType = typeof(string);

            column = result.Columns.Add("result");
            column.DataType = typeof(bool);

            result.Rows.Add(new object[] { "sol", "alta", "alta", "nao", false }); //D1 sol alta alta não N
            result.Rows.Add(new object[] { "sol", "alta", "alta", "sim", false }); //D2 sol alta alta sim N
            result.Rows.Add(new object[] { "nublado", "alta", "alta", "nao", true }); //D3 nebulado alta alta não P
            result.Rows.Add(new object[] { "chuva", "alta", "alta", "nao", true }); //D4 chuva alta alta não P
            result.Rows.Add(new object[] { "chuva", "baixa", "normal", "nao", true }); //D5 chuva baixa normal não P
            result.Rows.Add(new object[] { "chuva", "baixa", "normal", "sim", false }); //D6 chuva baixa normal sim N
            result.Rows.Add(new object[] { "nublado", "baixa", "normal", "sim", true }); //D7 nebulado baixa normal sim P
            result.Rows.Add(new object[] { "sol", "suave", "alta", "nao", false }); //D8 sol suave alta não N
            result.Rows.Add(new object[] { "sol", "baixa", "normal", "nao", true }); //D9 sol baixa normal não P
            result.Rows.Add(new object[] { "chuva", "suave", "normal", "nao", true }); //D10 chuva suave normal não P
            result.Rows.Add(new object[] { "sol", "suave", "normal", "nao", true }); //D11 sol suave normal sim P
            result.Rows.Add(new object[] { "nublado", "suave", "alta", "sim", true }); //D12 nebulado suave alta sim P
            result.Rows.Add(new object[] { "nublado", "alta", "normal", "nao", true }); //D13 nebulado alta normal não P
            result.Rows.Add(new object[] { "chuva", "suave", "alta", "sim", false }); //D14 chuva suave alta sim N

            return result;

        }


		public void Run()
		{
			Attribute ceu = new Attribute("ceu", new string[] {"sol", "nublado", "chuva"});
			Attribute temperatura = new Attribute("temperatura", new string[] {"alta", "baixa", "suave"});
			Attribute humidade = new Attribute("humidade", new string[] {"alta", "normal"});
			Attribute vento = new Attribute("vento", new string[] {"sim", "nao"});

			Attribute[] attributes = new Attribute[] {ceu, temperatura, humidade, vento};
			
			DataTable samples = getDataTable();			

			DecisionTreeID3 id3 = new DecisionTreeID3();
			TreeNode root = id3.mountTree(samples, "result", attributes);

			printNode(root, "");

		}
	}
}

    

