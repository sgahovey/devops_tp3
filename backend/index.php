<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Gérer les requêtes OPTIONS pour CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Configuration de la base de données
// Support pour DATABASE_URL (Railway, Render, Heroku, etc.) et configuration Docker Compose
$database_url = getenv('DATABASE_URL');

if ($database_url) {
    // Parse DATABASE_URL (format: postgresql://user:password@host:port/dbname)
    $db = parse_url($database_url);
    $host = $db['host'];
    $dbname = ltrim($db['path'], '/');
    $username = $db['user'];
    $password = $db['pass'];
    $port = isset($db['port']) ? $db['port'] : 5432;
} else {
    // Configuration conteneur unique (Railway)
    $host = getenv('DB_HOST') ?: '127.0.0.1';
    $dbname = getenv('DB_NAME') ?: 'gestion_salles';
    $username = getenv('DB_USER') ?: 'postgres';
    $password = getenv('DB_PASSWORD') ?: 'postgres';
    $port = getenv('DB_PORT') ?: 5432;
}

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Erreur de connexion à la base de données: ' . $e->getMessage()]);
    exit;
}

// Router simple
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/api', '', $path);

// Routes pour les salles
if (preg_match('/^\/salles\/?$/', $path)) {
    if ($method === 'GET') {
        getSalles($pdo);
    } elseif ($method === 'POST') {
        createSalle($pdo);
    }
} elseif (preg_match('/^\/salles\/(\d+)$/', $path, $matches)) {
    $id = $matches[1];
    if ($method === 'GET') {
        getSalle($pdo, $id);
    } elseif ($method === 'PUT') {
        updateSalle($pdo, $id);
    } elseif ($method === 'DELETE') {
        deleteSalle($pdo, $id);
    }
} elseif ($path === '/health') {
    echo json_encode(['status' => 'OK', 'message' => 'API de gestion des salles']);
} elseif ($path === '/metrics') {
    getMetrics($pdo);
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Route non trouvée']);
}

// Fonctions CRUD

function getSalles($pdo) {
    $stmt = $pdo->query('SELECT * FROM salles ORDER BY id');
    $salles = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($salles);
}

function getSalle($pdo, $id) {
    $stmt = $pdo->prepare('SELECT * FROM salles WHERE id = ?');
    $stmt->execute([$id]);
    $salle = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($salle) {
        echo json_encode($salle);
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'Salle non trouvée']);
    }
}

function createSalle($pdo) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['nom']) || !isset($data['capacite'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Données manquantes']);
        return;
    }
    
    $stmt = $pdo->prepare('INSERT INTO salles (nom, capacite, equipement, disponible) VALUES (?, ?, ?, ?)');
    $stmt->execute([
        $data['nom'],
        $data['capacite'],
        $data['equipement'] ?? '',
        $data['disponible'] ?? true
    ]);
    
    $id = $pdo->lastInsertId();
    http_response_code(201);
    echo json_encode(['id' => $id, 'message' => 'Salle créée avec succès']);
}

function updateSalle($pdo, $id) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $stmt = $pdo->prepare('UPDATE salles SET nom = ?, capacite = ?, equipement = ?, disponible = ? WHERE id = ?');
    $stmt->execute([
        $data['nom'],
        $data['capacite'],
        $data['equipement'] ?? '',
        $data['disponible'] ?? true,
        $id
    ]);
    
    echo json_encode(['message' => 'Salle mise à jour avec succès']);
}

function deleteSalle($pdo, $id) {
    $stmt = $pdo->prepare('DELETE FROM salles WHERE id = ?');
    $stmt->execute([$id]);
    
    echo json_encode(['message' => 'Salle supprimée avec succès']);
}

// Fonction pour exposer les métriques (format Prometheus)
function getMetrics($pdo) {
    header('Content-Type: text/plain; version=0.0.4');
    
    // Compte le nombre total de salles
    $stmt = $pdo->query('SELECT COUNT(*) as total FROM salles');
    $total = $stmt->fetch()['total'];
    
    // Compte les salles disponibles
    $stmt = $pdo->query('SELECT COUNT(*) as disponibles FROM salles WHERE disponible = true');
    $disponibles = $stmt->fetch()['disponibles'];
    
    // Compte les salles non disponibles
    $non_disponibles = $total - $disponibles;
    
    // Calcule la capacité totale
    $stmt = $pdo->query('SELECT SUM(capacite) as capacite_totale FROM salles');
    $capacite_totale = $stmt->fetch()['capacite_totale'] ?? 0;
    
    // Temps de réponse de la base de données
    $start_time = microtime(true);
    $pdo->query('SELECT 1');
    $db_response_time = (microtime(true) - $start_time) * 1000; // en millisecondes
    
    // Format Prometheus
    echo "# HELP salles_total Nombre total de salles\n";
    echo "# TYPE salles_total gauge\n";
    echo "salles_total $total\n\n";
    
    echo "# HELP salles_disponibles Nombre de salles disponibles\n";
    echo "# TYPE salles_disponibles gauge\n";
    echo "salles_disponibles $disponibles\n\n";
    
    echo "# HELP salles_non_disponibles Nombre de salles non disponibles\n";
    echo "# TYPE salles_non_disponibles gauge\n";
    echo "salles_non_disponibles $non_disponibles\n\n";
    
    echo "# HELP salles_capacite_totale Capacité totale de toutes les salles\n";
    echo "# TYPE salles_capacite_totale gauge\n";
    echo "salles_capacite_totale $capacite_totale\n\n";
    
    echo "# HELP db_response_time_ms Temps de réponse de la base de données en millisecondes\n";
    echo "# TYPE db_response_time_ms gauge\n";
    echo "db_response_time_ms $db_response_time\n\n";
    
    echo "# HELP api_up API est opérationnelle (1 = up, 0 = down)\n";
    echo "# TYPE api_up gauge\n";
    echo "api_up 1\n";
}


