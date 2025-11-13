const { query } = require('../database');
const path = require('path');

// ========================
// ABRIR PÁGINA CRUD CARRINHO
// ========================
exports.abrirCrudCarrinho = (req, res) => {
  console.log('Rota abrirCrudCarrinho acessada');
  res.sendFile(path.join(__dirname, '../../frontend/carrinho/carrinho.html'));
};

// ========================
// LISTAR TODOS OS CARRINHOS
// ========================
exports.listarCarrinhos = async (req, res) => {
  try {
    const result = await query(`
      SELECT id_carrinho, cpf_cliente, data_pedido
      FROM CARRINHO
      ORDER BY id_carrinho;
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Erro ao listar carrinhos:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// ========================
// CRIAR NOVO CARRINHO
// ========================
exports.criarCarrinho = async (req, res) => {
  try {
    const { id_carrinho, cpf_cliente, data_pedido } = req.body;

    if (!cpf_cliente || !data_pedido) {
      return res.status(400).json({ error: 'Campos obrigatórios não fornecidos' });
    }

    const idInt = parseInt(id_carrinho);
    if (isNaN(idInt)) return res.status(400).json({ error: 'id_carrinho deve ser um número inteiro válido' });

    // Insere o carrinho
    const result = await query(
      `INSERT INTO CARRINHO (id_carrinho, cpf_cliente, data_pedido)
       VALUES ($1, $2, $3) RETURNING *`,
      [idInt, cpf_cliente, data_pedido]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao criar carrinho:', error);
    if (error.code === '23505') {
      return res.status(400).json({ error: 'id_carrinho já está em uso' });
    }
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// ========================
// OBTER CARRINHO POR ID
// ========================
exports.obterCarrinho = async (req, res) => {
  try {
    const id_carrinho = parseInt(req.params.id);
    if (isNaN(id_carrinho)) return res.status(400).json({ error: 'id_carrinho deve ser um número válido' });

    const result = await query(
      `SELECT id_carrinho, cpf_cliente, data_pedido
       FROM CARRINHO
       WHERE id_carrinho = $1`,
      [id_carrinho]
    );

    if (result.rows.length === 0) return res.status(404).json({ error: 'Carrinho não encontrado' });

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao obter carrinho:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// ========================
// ATUALIZAR CARRINHO
// ========================
exports.atualizarCarrinho = async (req, res) => {
  try {
    const id_carrinho = parseInt(req.params.id);
    const { cpf_cliente, data_pedido } = req.body;

    if (isNaN(id_carrinho)) return res.status(400).json({ error: 'id_carrinho inválido' });

    const existing = await query(`SELECT * FROM CARRINHO WHERE id_carrinho = $1`, [id_carrinho]);
    if (existing.rows.length === 0) return res.status(404).json({ error: 'Carrinho não encontrado' });

    const carrinho = existing.rows[0];

    const result = await query(
      `UPDATE CARRINHO SET
        cpf_cliente = $1,
        data_pedido = $2
       WHERE id_carrinho = $3 RETURNING *`,
      [
        cpf_cliente ?? carrinho.cpf_cliente,
        data_pedido ?? carrinho.data_pedido,
        id_carrinho
      ]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao atualizar carrinho:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// ========================
// DELETAR CARRINHO
// ========================
exports.deletarCarrinho = async (req, res) => {
  try {
    const id_carrinho = parseInt(req.params.id);
    if (isNaN(id_carrinho)) return res.status(400).json({ error: 'id_carrinho inválido' });

    const existing = await query(`SELECT * FROM CARRINHO WHERE id_carrinho = $1`, [id_carrinho]);
    if (existing.rows.length === 0) return res.status(404).json({ error: 'Carrinho não encontrado' });

    await query(`DELETE FROM CARRINHO WHERE id_carrinho = $1`, [id_carrinho]);

    res.status(204).send();
  } catch (error) {
    console.error('Erro ao deletar carrinho:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};
