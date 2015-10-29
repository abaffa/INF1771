using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IA_DecisionTree_Example
{
    /// <summary>
    /// Classe que representará a arvore de decisão montada;
    /// </summary>
    public class TreeNode
    {
        private ArrayList mChilds = null;
        private Attribute mAttribute;

        /// <summary>
        /// Inicializa uma nova instância de TreeNode
        /// </summary>
        /// <param name="attribute">Atributo ao qual o node está ligado</param>
        public TreeNode(Attribute attribute)
        {
            if (attribute.values != null)
            {
                mChilds = new ArrayList(attribute.values.Length);
                for (int i = 0; i < attribute.values.Length; i++)
                    mChilds.Add(null);
            }
            else
            {
                mChilds = new ArrayList(1);
                mChilds.Add(null);
            }
            mAttribute = attribute;
        }

        /// <summary>
        /// Adiciona um TreeNode filho a este treenode no galho de nome indicicado pelo ValueName
        /// </summary>
        /// <param name="treeNode">TreeNode filho a ser adicionado</param>
        /// <param name="ValueName">Nome do galho onde o treeNode é criado</param>
        public void AddTreeNode(TreeNode treeNode, string ValueName)
        {
            int index = mAttribute.indexValue(ValueName);
            mChilds[index] = treeNode;
        }

        /// <summary>
        /// Retorna o nro total de filhos do nó
        /// </summary>
        public int totalChilds
        {
            get
            {
                return mChilds.Count;
            }
        }

        /// <summary>
        /// Retorna o nó filho de um nó
        /// </summary>
        /// <param name="index">Indice do nó filho</param>
        /// <returns>Um objeto da classe TreeNode representando o nó</returns>
        public TreeNode getChild(int index)
        {
            return (TreeNode)mChilds[index];
        }

        /// <summary>
        /// Atributo que está conectado ao Nó
        /// </summary>
        public Attribute attribute
        {
            get
            {
                return mAttribute;
            }
        }

        /// <summary>
        /// Retorna o filho de um nó pelo nome do galho que leva até ele
        /// </summary>
        /// <param name="branchName">Nome do galho</param>
        /// <returns>O nó</returns>
        public TreeNode getChildByBranchName(string branchName)
        {
            int index = mAttribute.indexValue(branchName);
            return (TreeNode)mChilds[index];
        }
    }
}
