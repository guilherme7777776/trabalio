const { query } = require('../database');
const path = require('path');

// ===================================
// ABRIR PÁGINA CRUD FUNCIONÁRIO
// ===================================
exports.abrirCrudFuncionario = (req, res) => {
  console.log('Rota abrirCrudFuncionario acessada');
  res.sendFile(path.join(__dirname, '../../frontend/funcionario/funcionario.html'));
};

// ===================================
// LISTAR FUNCIONÁRIOS
// ===================================
exports.listarFuncionarios = async (req, res) => {
  try {
    const result = await query(`
      SELECT 
        f.id_pessoa,
        p.nome_pessoa,
        p.email_pessoa,
        p.senha_pessoa,
        p.endereco_pessoa,
        p.telefone_pessoa,
        f.salario_funcionario,
        f.carga_horaria,
        f.comissao,
        f.id_cargo,
        c.nome_cargo
      FROM FUNCIONARIO f
      JOIN PESSOA p ON f.id_pessoa = p.id_pessoa
      LEFT JOIN CARGO c ON f.id_cargo = c.id_cargo
      ORDER BY f.id_pessoa;
    `);

    res.json(result.rows);
  } catch (error) {
    console.error('Erro ao listar funcionários:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// ===================================
// CRIAR FUNCIONÁRIO
// ===================================
exports.criarFuncionario = async (req, res) => {
  try {
    const {
      id_pessoa,
      nome_pessoa,
      email_pessoa,
      senha_pessoa,
      endereco_pessoa,
      telefone_pessoa,
      data_nascimento,
      funcionario,
      carga_horaria,
      comissao,
      id_cargo
    } = req.body;

    if (!id_pessoa || !nome_pessoa || !email_pessoa || !senha_pessoa || !funcionario || !carga_horaria || !comissao) {
      return res.status(400).json({ error: 'Campos obrigatórios não fornecidos' });
    }

    const idInt = parseInt(id_pessoa);
    if (isNaN(idInt)) {
      return res.status(400).json({ error: 'id_pessoa deve ser numérico' });
    }

    // Cria pessoa
    await query(
      `INSERT INTO PESSOA (id_pessoa, nome_pessoa, email_pessoa, senha_pessoa, endereco_pessoa, telefone_pessoa, data_nascimento)
       VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [idInt, nome_pessoa, email_pessoa, senha_pessoa, endereco_pessoa, telefone_pessoa, data_nascimento]
    );

    // Cria funcionário
    const result = await query(
      `INSERT INTO FUNCIONARIO (id_pessoa, funcionario, carga_horaria, comissao, id_cargo)
       VALUES ($1,$2,$3,$4) RETURNING *`,
      [idInt, funcionario, carga_horaria, comissao, id_cargo || null]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao criar funcionário:', error);
    if (error.code === '23505') {
      return res.status(400).json({ error: 'id_pessoa ou email já estão em uso' });
    }
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// ===================================
// OBTER FUNCIONÁRIO POR ID
// ===================================
exports.obterFuncionario = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });

    const result = await query(`
      SELECT 
        f.id_pessoa,
        p.nome_pessoa AS nome,
        p.email_pessoa AS email,
        p.endereco_pessoa AS endereco,
        p.telefone_pessoa AS telefone,
        p.data_nascimento,
        f.salario_funcionario,
        f.carga_horaria,
        f.comissao,
        f.id_cargo
      FROM FUNCIONARIO f
      JOIN PESSOA p ON f.id_pessoa = p.id_pessoa
      WHERE f.id_pessoa = $1
    `, [id]);
  

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Funcionário não encontrado' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao obter funcionário:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// ===================================
// ATUALIZAR FUNCIONÁRIO
// ===================================
exports.atualizarFuncionario = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const {
      nome_pessoa,
      email_pessoa,
      senha_pessoa,
      endereco_pessoa,
      telefone_pessoa,
      data_nascimento,
      funcionario,
      carga_horaria,
      comissao,
      id_cargo
    } = req.body;

    if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });

    const existing = await query(`SELECT * FROM FUNCIONARIO WHERE id_pessoa = $1`, [id]);
    if (existing.rows.length === 0) return res.status(404).json({ error: 'Funcionário não encontrado' });

    // Atualiza pessoa
    await query(
      `UPDATE PESSOA 
         SET nome_pessoa=$1, email_pessoa=$2, senha_pessoa=$3,
             endereco_pessoa=$4, telefone_pessoa=$5, data_nascimento=$6
       WHERE id_pessoa=$7`,
      [nome_pessoa, email_pessoa, senha_pessoa, endereco_pessoa, telefone_pessoa, data_nascimento, id]
    );

    // Atualiza funcionário
    const result = await query(
      `UPDATE FUNCIONARIO 
         SET funcionario=$1, carga_horaria=$2, comissao=$3 id_cargo=$4
       WHERE id_pessoa=$4 RETURNING *`,
      [funcionario, carga_horaria, comissao, id_cargo, id]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao atualizar funcionário:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// ===================================
// DELETAR FUNCIONÁRIO
// ===================================
exports.deletarFuncionario = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });

    const existing = await query(`SELECT * FROM FUNCIONARIO WHERE id_pessoa=$1`, [id]);
    if (existing.rows.length === 0) return res.status(404).json({ error: 'Funcionário não encontrado' });

    await query(`DELETE FROM PESSOA WHERE id_pessoa=$1`, [id]);

    res.status(204).send();
  } catch (error) {
    console.error('Erro ao deletar funcionário:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};
