using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IA_DecisionTree_Example
{
/// <summary>
	/// Classe que representa um atributo utilizado na classe de decisão
	/// </summary>
	public class Attribute
	{
		ArrayList mValues;
		string mName;
		object mLabel;

		/// <summary>
		/// Inicializa uma nova instância de uma classe Atribute
		/// </summary>
		/// <param name="name">Indica o nome do atributo</param>
		/// <param name="values">Indica os valores possíveis para o atributo</param>
		public Attribute(string name, string[] values)
		{
			mName = name;
			mValues = new ArrayList(values);
			mValues.Sort();
		}

		public Attribute(object Label)
		{
			mLabel = Label;
			mName = string.Empty;
			mValues = null;
		}

		/// <summary>
		/// Indica o nome do atributo
		/// </summary>
		public string AttributeName
		{
			get
			{
				return mName;
			}
		}

		/// <summary>
		/// Retorna um array com os valores do atributo
		/// </summary>
		public string[] values
		{
			get
			{
				if (mValues != null)
					return (string[])mValues.ToArray(typeof(string));
				else
					return null;
			}
		}

		/// <summary>
		/// Indica se um valor é permitido para este atributo
		/// </summary>
		/// <param name="value"></param>
		/// <returns></returns>
		public bool isValidValue(string value)
		{
			return indexValue(value) >= 0;
		}

		/// <summary>
		/// Retorna o índice de um valor
		/// </summary>
		/// <param name="value">Valor a ser retornado</param>
		/// <returns>O valor do índice na qual a posição do valor se encontra</returns>
		public int indexValue(string value)
		{
			if (mValues != null)
				return mValues.BinarySearch(value);
			else
				return -1;
		}

		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		public override string ToString()
		{
			if (mName != string.Empty)
			{
				return mName;
			}
			else
			{
				return mLabel.ToString();
			}
		}
	}
}
