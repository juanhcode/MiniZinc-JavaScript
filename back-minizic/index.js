const express = require('express');
const { exec } = require('child_process');
const fs = require('fs');

const app = express();
const PORT = 3000;

// Middleware para manejar CORS y otras configuraciones necesarias
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// Endpoint para recibir el código MiniZinc y ejecutarlo
app.post('/execute', express.json(), (req, res) => {
    const { code } = req.body;

    if (!code || !code.trim()) {
        return res.status(400).json({ error: 'El código MiniZinc está vacío.' });
    }

    const filePath = 'temp.mzn';
    fs.writeFileSync(filePath, code);

    exec(`minizinc --solver COIN-BC temp.mzn`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error ejecutando MiniZinc: ${stderr}`);
            return res.status(500).json({ error: stderr });
        }
        console.log(`MiniZinc ejecutado correctamente: ${stdout}`);
        res.json({ output: stdout });
    });
});

// Iniciar servidor HTTP
app.listen(PORT, () => {
    console.log(`Servidor HTTP corriendo en http://localhost:${PORT}`);
});
