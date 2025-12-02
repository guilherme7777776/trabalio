const express = require('express');
const router = express.Router();

const cargoController = require('./../controllers/cargoController');

// LISTAR CARGOS
router.get('/abrirCrudCargo', cargoController.abrirCrudCargo);
router.get('/', cargoController.listarCargos);

module.exports = router;
