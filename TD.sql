/*Afficher le nombre de commande totales supérieur à 50e que l’on a dans le catalogue et la moyenne des prix des commandes*/

SELECT COUNT(DISTINCT pc.commande_id) AS nombre_commandes, 
AVG(p.price) AS moyenne_prix 
FROM product_commande AS pc JOIN commande AS c ON pc.commande_id = c.id 
JOIN product AS p ON pc.product_id = p.id WHERE p.price > 50;

/*Insérer 3 nouvelles promotion pour les produits de chez Apple ou tagué “Siri’ (en SQL)*/

INSERT INTO promotion (title, taux, enabled)
SELECT CONCAT('Promotion Apple', n), FLOOR(RAND() * 100) + 1
, 1
FROM (
  SELECT 1 AS n UNION ALL
  SELECT 2 AS n UNION ALL
  SELECT 3 AS n
) numbers
WHERE EXISTS (
  SELECT *
  FROM product AS p
    JOIN tags_product tp ON p.id = tp.product_id
    JOIN tags t ON tp.tags_id = t.id
     WHERE p.title LIKE '%Apple%' OR t.title LIKE '%Siri%'
)
LIMIT 3;

/*Gérer les marques pour les produits (1 produit a 1 seul marque) avec title et localisation(ville)*/

CREATE TABLE marque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(255),
    localisation VARCHAR(255)
);

ALTER TABLE product
ADD FOREIGN KEY (marque_id) REFERENCES marque(id);

ALTER TABLE product ADD COLUMN marque_id INT;

INSERT INTO marque (id, titre, localisation)
VALUES (1, 'Apple', 'Lyon'),
       (2, 'Samsung', 'Villefranche sur Saône'),
       (3, 'Huawei', 'Lille');


UPDATE product
SET marque_id = (CASE
                    WHEN title = '%Apple%' THEN 1
                    WHEN title = '%Samsung%' THEN 2
                    WHEN title = '%Huawei%' THEN 3
                    ELSE NULL
                 END);


/*Afficher le nombre de marques par produits qui sont de Lyon*/

SELECT p.title, COUNT(*) AS nombre_marques_lyon
FROM product AS p
JOIN marque AS m ON p.marque_id = m.id
WHERE m.localisation = 'Lyon'
GROUP BY p.title;

/*Gérer les avis des utilisateurs sur les produits :*/

CREATE TABLE avis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content TEXT,
    rating VARCHAR(3),
    produit_id INT,
    utilisateur_id INT,
    FOREIGN KEY (produit_id) REFERENCES produit (id),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur (id)
);

/* Supprimer les avis à 0 ou dont le contenu est inférieur à 3 mots*/

DELETE FROM avis
WHERE rating = 0 OR LENGTH(content) - LENGTH(REPLACE(content, ' ', '')) + 1 < 3;

/*Gérer les cartes de fidélité pour les utilisateurs (1 à 1).*/

ALTER TABLE `user` ADD COLUMN loyalty_card_id INT;

CREATE TABLE loyalty_card (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255)
);

ALTER TABLE `user`
ADD FOREIGN KEY (loyalty_card_id) REFERENCES loyalty_card(id);

/*Afficher le nom des cartes de fidélité sur les 3 dernières commandes des utilisateurs :*/

SELECT c.id, c.created, cf.title AS nom_carte_fidélité
FROM commande AS c
JOIN user AS u ON c.user_id = u.id
JOIN loyalty_card AS cf ON u.loyalty_card_id = cf.id
ORDER BY c.created DESC
LIMIT 3;

/*Gérer les fournisseurs pour les produits. Attention 1 produit peut avoir plusieurs fournisseurs à la fois.*/

CREATE TABLE supplier (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    adress VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE supplier_product (
    supplier_id INT,
    product_id INT,
    FOREIGN KEY (supplier_id) REFERENCES supplier(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
);

/*Afficher les fournisseurs qui fournissent le plus de produits depuis 2 ans ou plus*/

SELECT f.name, COUNT(*) AS nombre_produits_fournis
FROM supplier_product AS fp
JOIN supplier AS f ON fp.supplier_id = f.id
JOIN product AS p ON fp.product_id = p.id
JOIN product_commande AS pc ON p.id = pc.product_id
JOIN commande AS c ON pc.commande_id = c.id
WHERE c.created >= DATE_SUB(NOW(), INTERVAL 2 YEAR)
GROUP BY f.name
ORDER BY COUNT(*) DESC
LIMIT 1;

/*Gérer les administrateurs. Les administrateurs sont des super utilisateurs et on affichera les 2 derniers administrateurs créer. 
Parmis ces admins, il y aura 1 seul super-admin.*/


CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    super_admin TINYINT
);

INSERT INTO admin (name, super_admin)
VALUES ('Bezos', 0),
       ('Musk', 1),
       ('Depardieu', 0);

-- Afficher les 2 derniers administrateurs créés
SELECT *
FROM admin
ORDER BY id DESC
LIMIT 2;

/*Gérer les adresses de facturation et livraison pour les utilisateurs avec les champs:
- pays
- Région
- CP
- adresse
- ville,
- longitude
- latitude */

CREATE TABLE adress_facturation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    country VARCHAR(255),
    region VARCHAR(255),
    postal_code VARCHAR(255),
    adress VARCHAR(255),
    city VARCHAR(255),
    longitude DECIMAL(10, 6),
    latitude DECIMAL(10, 6),
    FOREIGN KEY (user_id) REFERENCES user (id)
);

CREATE TABLE adress_shipping (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    country VARCHAR(255),
    region VARCHAR(255),
    postal_code VARCHAR(255),
    adress VARCHAR(255),
    city VARCHAR(255),
    longitude DECIMAL(10, 6),
    latitude DECIMAL(10, 6),
    FOREIGN KEY (user_id) REFERENCES user (id)
);