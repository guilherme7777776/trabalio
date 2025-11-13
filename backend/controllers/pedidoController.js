//import { query } from '../database.js';
const { query } = require('../database');
// Funções do controller

const path = require('path');

exports.abrirCrudPedido = (req, res) => {
  // console.log('pedidoController - Rota /abrirCrudPedido - abrir o crudPedido');
  res.sendFile(path.join(__dirname, '../../frontend/pedido/pedido.html'));
}

exports.listarPedidos = async (req, res) => {
  try {
    const result = await query('SELECT * FROM P ORDER PEDIDO');
    //  console.log('Resultado do SELECT:', result.rows);//verifica se está retornando algo
    res.json(result.rows);
  } catch (error) {
    console.error('Erro ao listar pedidos:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
}

exports.criarPedido = async (req, res) => {
  try {
    const { id_pedido, data_pedido, id_pessoa, id_funcionario} = req.body;

    if (!carrinho || !data_pedido || !id_pessoa || !id_funcionario) {
      return res.status(400).json({ error: 'Todos os campos são obrigatórios: id_pedido, data_pedido, id_pessoa, id_funcionario.' });
    }

    const result = await query(
      'INSERT INTO CARRINHO (id_pedido, data_pedido, id_pessoa, id_funcionario) VALUES ($1, $2, $3, $4) RETURNING *',
      [id_pedido, data_pedido, id_pessoa, id_funcionario]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao criar pedido:', error);

    // Verifica se é erro de violação de constraint NOT NULL
    if (error.code === '23502') {
      return res.status(400).json({
        error: 'Dados obrigatórios não fornecidos'
      });
    }

    // Verifica se é erro de violação de foreign key
    if (error.code === '23503') {
      return res.status(400).json({
        error: 'Cliente ou funcionário não encontrados'
      });
    }

    res.status(500).json({ error: 'Erro interno do servidor' });
  }
}

exports.obterPedido = async (req, res) => {
  try {
    const id = parseInt(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({ error: 'ID deve ser um número válido' });
    }

    const result = await query(
      'SELECT * FROM PEDIDO WHERE id_pedido = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao obter pedido:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
}

exports.atualizarPedido = async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });

    const { data_pedido, id_pessoa, id_funcionario } = req.body;

    // Verifica se o pedido existe
    const existing = await query('SELECT * FROM PEDIDO WHERE id_pedido = $1', [id]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }

    // Atualiza o pedido
    const sql = `
      UPDATE PEDIDO
      SET data_pedido = $1,
          id_pessoa = $2,
          id_funcionario = $3
      WHERE id_pedido = $4
      RETURNING *
    `;
    const values = [data_pedido, id_pessoa, id_funcionario, id];

    const updateResult = await query(sql, values);
    return res.json(updateResult.rows[0]);
  } catch (error) {
    console.error('Erro ao atualizar pedido:', error);
    return res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

exports.deletarPedido = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });

    // Verifica se o pedido existe
    const existingPersonResult = await query(
      'SELECT * FROM PEDIDO WHERE id_pedido = $1',
      [id]
    );

    if (existingPersonResult.rows.length === 0) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }

    // Deleta o pedido (constraints CASCADE cuidam das dependências)
    await query(
      'DELETE FROM PEDIDO WHERE id_pedido = $1',
      [id]
    );

    res.status(204).send();
  } catch (error) {
    console.error('Erro ao deletar pedido:', error);

    if (error.code === '23503') {
      return res.status(400).json({
        error: 'Não é possível deletar pedido com dependências associadas'
      });
    }

    res.status(500).json({ error: 'Erro interno do servidor' });
  }
}
