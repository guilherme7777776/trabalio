const { query } = require('../database');
const path = require('path');

// Abre o CRUD de pessoa
exports.abrirCrudPessoa = (req, res) => {
  const usuario = req.cookies.usuarioLogado; // Cookie com usuário logado


  res.sendFile(path.join(__dirname, '../../frontend/pessoa/pessoa.html'));
 
};

// Listar todas as pessoas
exports.listarPessoas = async (req, res) => {
  try {
    const result = await query('SELECT * FROM PESSOA ORDER BY id_pessoa');
    res.json(result.rows);
  } catch (error) {
    console.error('Erro ao listar pessoas:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Criar nova pessoa
exports.criarPessoa = async (req, res) => {
  try {
    const { id_pessoa, nome_pessoa, data_nascimento, endereco_pessoa, senha_pessoa, email_pessoa } = req.body;

    // Validação básica obrigatória
    if (!nome_pessoa || !endereco_pessoa || !senha_pessoa || !email_pessoa) {
      return res.status(400).json({ error: 'Nome, email, endereço e senha são obrigatórios' });
    }

    // Validação de email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email_pessoa)) {
      return res.status(400).json({ error: 'Formato de email inválido' });
    }

    const result = await query(
      'INSERT INTO pessoa (id_pessoa, nome_pessoa, data_nascimento, endereco_pessoa, senha_pessoa, email_pessoa) VALUES ($1,$2,$3,$4,$5,$6) RETURNING *',
      [id_pessoa, nome_pessoa, data_nascimento, endereco_pessoa, senha_pessoa, email_pessoa]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao criar pessoa:', error);

    if (error.code === '23505' && error.constraint === 'pessoa_unique') {
      return res.status(400).json({ error: 'Email já está em uso' });
    }
    if (error.code === '23502') {
      return res.status(400).json({ error: 'Dados obrigatórios não fornecidos' });
    }

    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Obter pessoa por CPF
exports.obterPessoa = async (req, res) => {
  try {
    const id = req.params.id;

    const result = await query('SELECT * FROM PESSOA WHERE id_pessoa = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pessoa não encontrada' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao obter pessoa:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Atualizar dados da pessoa
exports.atualizarPessoa = async (req, res) => {
  try {
    const id = req.params.id;
    const { nome_pessoa, data_nascimento, endereco_pessoa, senha_pessoa, email_pessoa } = req.body;

    // Validação de email, se fornecido
    if (email_pessoa) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email_pessoa)) {
        return res.status(400).json({ error: 'Formato de email inválido' });
      }
    }

    // Verifica existência
    const existing = await query('SELECT * FROM pessoa WHERE id_pessoa = $1', [id]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ error: 'Pessoa não encontrada' });
    }

    const current = existing.rows[0];
    const updatedFields = {
      nome_pessoa: nome_pessoa ?? current.nome_pessoa,
      data_nascimento: data_nascimento ?? current.data_nascimento,
      endereco_pessoa: endereco_pessoa ?? current.endereco_pessoa,
      senha_pessoa: senha_pessoa ?? current.senha_pessoa,
      email_pessoa: email_pessoa ?? current.email_pessoa
    };

    const updateResult = await query(
      'UPDATE pessoa SET nome_pessoa=$1, data_nascimento=$2, endereco_pessoa=$3, senha_pessoa=$4, email_pessoa=$5 WHERE id_pessoa=$6 RETURNING *',
      [updatedFields.nome_pessoa, updatedFields.data_nascimento, updatedFields.endereco_pessoa, updatedFields.senha_pessoa, updatedFields.email_pessoa, id]
    );

    res.json(updateResult.rows[0]);
  } catch (error) {
    console.error('Erro ao atualizar pessoa:', error);
    if (error.code === '23505' && error.constraint === 'pessoa_unique') {
      return res.status(400).json({ error: 'Email já está em uso por outra pessoa' });
    }
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Deletar pessoa
exports.deletarPessoa = async (req, res) => {
  try {
    const id = req.params.id;
    const existing = await query('SELECT * FROM PESSOA WHERE id_pessoa = $1', [id]);

    if (existing.rows.length === 0) {
      return res.status(404).json({ error: 'Pessoa não encontrada' });
    }

    await query('DELETE FROM PESSOA WHERE id_pessoa = $1', [id]);
    res.status(204).send();
  } catch (error) {
    console.error('Erro ao deletar pessoa:', error);
    if (error.code === '23503') {
      return res.status(400).json({ error: 'Não é possível deletar pessoa com dependências associadas' });
    }
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Buscar pessoa por email
exports.obterPessoaPorEmail = async (req, res) => {
  try {
    const { email_pessoa } = req.params;

    if (!email_pessoa) return res.status(400).json({ error: 'Email é obrigatório' });

    const result = await query('SELECT * FROM PESSOA WHERE email_pessoa = $1', [email_pessoa]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Pessoa não encontrada' });

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erro ao obter pessoa por email:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Atualizar somente a senha
exports.atualizarSenha = async (req, res) => {
  try {
    const id = req.params.id;
    const { senha_atual, nova_senha } = req.body;

    if (!senha_atual || !nova_senha) {
      return res.status(400).json({ error: 'Senha atual e nova senha são obrigatórias' });
    }

    const result = await query('SELECT * FROM PESSOA WHERE id_pessoa = $1', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Pessoa não encontrada' });

    const pessoa = result.rows[0];
    if (pessoa.senha_pessoa !== senha_atual) {
      return res.status(400).json({ error: 'Senha atual incorreta' });
    }

    const updateResult = await query(
      'UPDATE PESSOA SET senha_pessoa = $1 WHERE id_pessoa = $2 RETURNING id_pessoa, nome_pessoa, endereco_pessoa, data_nascimento',
      [nova_senha, id]
    );

    res.json(updateResult.rows[0]);
  } catch (error) {
    console.error('Erro ao atualizar senha:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};
