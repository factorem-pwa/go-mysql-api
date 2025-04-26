package main

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

// Product model (same as before)
type Product struct {
	gorm.Model
	Name  string  `json:"name"`
	Price float64 `json:"price"`
}

var DB *gorm.DB

func main() {
	// Initialize Fiber
	app := fiber.New()
	app.Use(cors.New())
	app.Use(logger.New())

	// MySQL connection (replace credentials)
	dsn := "user:password@tcp(db:3306)/products?charset=utf8mb4&parseTime=True&loc=Local"
	DB, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("Failed to connect to MySQL: " + err.Error())
	}
	DB.AutoMigrate(&Product{})

	// Routes (same as before)
	app.Get("/api/products", getProducts)
	app.Post("/api/products", createProduct)
	app.Delete("/api/products/:id", deleteProduct)

	// Start server
	app.Listen(":3000")
}

// Handlers (unchanged)
func getProducts(c *fiber.Ctx) error {
	var products []Product
	DB.Find(&products)
	return c.JSON(products)
}

func createProduct(c *fiber.Ctx) error {
	product := new(Product)
	if err := c.BodyParser(product); err != nil {
		return c.Status(400).SendString(err.Error())
	}
	DB.Create(&product)
	return c.JSON(product)
}

func deleteProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	DB.Delete(&Product{}, id)
	return c.SendStatus(204)
}