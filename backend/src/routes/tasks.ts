import { Router } from "express";
import { prisma } from "../data/prisma";
import { authMiddleware, AuthRequest } from "../middleware/auth";

const router = Router();


router.use((req, res, next) => {
  console.log(`[Tasks API] ${req.method} ${req.originalUrl}`);
  if (Object.keys(req.body).length > 0) {
    console.log("  Body:", req.body);
  }
  next();
});


router.use(authMiddleware);

// Get tasks
router.get("/", async (req: AuthRequest, res) => {
  console.log(`[Tasks API] Fetching tasks for user: ${req.user!.email}`);
  const tasks = await prisma.task.findMany({
    where: { userId: req.user!.userId },
  });
  res.json(tasks);
});

// Create task
router.post("/", async (req: AuthRequest, res) => {
  console.log(`[Tasks API] Creating new task for user: ${req.user!.email}`);
  const { title, description } = req.body;
  if (!title || !description) {
    return res
      .status(400)
      .json({ message: "Title and description required" });
  }

  const newTask = await prisma.task.create({
    data: {
      title,
      description,
      userId: req.user!.userId,
    },
  });

  console.log("Created Task:", newTask);
  res.json(newTask);
});

// Update task
router.put("/:id", async (req: AuthRequest, res) => {
  const { id } = req.params;
  console.log(`[Tasks API] Updating task ${id} for user: ${req.user!.email}`);

  const task = await prisma.task.findFirst({
    where: { id, userId: req.user!.userId },
  });
  if (!task) {
    console.log("Task not found or unauthorized");
    return res.status(404).json({ message: "Task not found" });
  }

  const { title, description, status } = req.body;
  const updated = await prisma.task.update({
    where: { id },
    data: { title, description, status },
  });

  console.log("  Updated Task:", updated);
  res.json(updated);
});

// Delete task
router.delete("/:id", async (req: AuthRequest, res) => {
  const { id } = req.params;
  console.log(`[Tasks API] Deleting task ${id} for user: ${req.user!.email}`);

  const task = await prisma.task.findFirst({
    where: { id, userId: req.user!.userId },
  });
  if (!task) {
    console.log("  Task not found or unauthorized");
    return res.status(404).json({ message: "Task not found" });
  }

  await prisma.task.delete({ where: { id } });
  console.log("  Task deleted successfully");
  res.json({ message: "Task deleted" });
});

export default router;
