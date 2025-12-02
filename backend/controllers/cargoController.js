const { query } = require('../database');


exports.abrirCrudCargo = (req, res) => {
  console.log('Rota abrirCrudcargo acessada');
  res.sendFile(path.join(__dirname, '../../frontend/cargo/cargo.html'));
};

// LISTAR CARGOS
exports.listarCargos = async (req, res) => {
  try {
    const result = await query(`SELECT * FROM CARGO ORDER BY id_cargo`);
    res.json(result.rows);
  } catch (error) {
    console.error("Erro ao listar cargos:", error);
    res.status(500).json({ error: "Erro ao listar cargos" });
  }
};
