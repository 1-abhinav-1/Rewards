const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const CONTRACT_ADDRESS = "0xc8a52a71eb01c6b890bd0c7043a423d1e0beeffb41add865dc296ff0008c8982";

// API Endpoint to get contract details
app.get('/contract', (req, res) => {
    res.json({ contractAddress: CONTRACT_ADDRESS });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
