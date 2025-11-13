
const express = require('express');
const router = express.Router();
const item_pedidoController = require('./../controllers/item_pedidoController');

// CRUD de item_pedidos
// Rotas para a PK composta: pedido_id e produto_id
router.get('/:id_pedido/:id_produto', item_pedidoController.obteritem_pedido);
router.put('/:id_pedido/:id_produto', item_pedidoController.atualizaritem_pedido);
router.delete('/:id_pedido/:id_produto', item_pedidoController.deletaritem_pedido);

// Outras rotas sem a PK composta
router.get('/abrirCruditem_pedido', item_pedidoController.abrirCruditem_pedido);
router.get('/', item_pedidoController.listaritem_pedido);


// Rota para obter todos os itens de um pedido específico
router.get('/:idPedido', item_pedidoController.obterItensDeUmitem_pedido);
router.post('/', item_pedidoController.criaritem_pedido);

module.exports = router;
