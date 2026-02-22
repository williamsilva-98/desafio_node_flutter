const AppError = require("../../../shared/errors/app_error");
const userService = require("../user_service");
const userRepository = require("../user_repository");

jest.mock("../user_repository", () => ({
  create: jest.fn(),
  findAll: jest.fn(),
}));

describe("user_service", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("createUser", () => {
    test("throws AppError when name is not provided", async () => {
      await expect(
        userService.createUser({ email: "a@b.com" }),
      ).rejects.toThrow("Name is required.");

      await expect(
        userService.createUser({ name: "", email: "a@b.com" }),
      ).rejects.toThrow("Name is required.");

      await expect(
        userService.createUser({ name: "   ", email: "a@b.com" }),
      ).rejects.toThrow("Name is required.");

      expect(userRepository.create).not.toHaveBeenCalled();
    });

    test("throws AppError when email is not provided", async () => {
      await expect(userService.createUser({ name: "William" })).rejects.toThrow(
        "Email is required.",
      );

      await expect(
        userService.createUser({ name: "William", email: "" }),
      ).rejects.toThrow("Email is required.");

      await expect(
        userService.createUser({ name: "William", email: "   " }),
      ).rejects.toThrow("Email is required.");

      expect(userRepository.create).not.toHaveBeenCalled();
    });

    test("throws AppError with statusCode 409 when email is already registered", async () => {
      userRepository.findAll.mockResolvedValue([
        { id: 1, email: "william@email.com" },
      ]);

      try {
        await userService.createUser({
          name: "William",
          email: "william@email.com",
        });
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect(error.message).toBe(
          "User already exists with this email.",
        );
        expect(error.statusCode).toBe(409);
      }

      expect(userRepository.findAll).toHaveBeenCalledWith({
        email: "william@email.com",
      });
      expect(userRepository.create).not.toHaveBeenCalled();
    });

    test("creates user with valid name and email", async () => {
      userRepository.findAll.mockResolvedValue([]);
      userRepository.create.mockResolvedValue({
        id: 1,
        name: "William",
        email: "william@email.com",
      });

      const result = await userService.createUser({
        name: "William",
        email: "william@email.com",
      });

      expect(result).toEqual({
        id: 1,
        name: "William",
        email: "william@email.com",
      });
      expect(userRepository.findAll).toHaveBeenCalledWith({
        email: "william@email.com",
      });
      expect(userRepository.create).toHaveBeenCalledWith(
        "William",
        "william@email.com",
      );
    });
  });

  describe("getAllUsers", () => {
    test("lists users with name filter", async () => {
      const mockList = [{ id: 1, name: "William", email: "william@email.com" }];
      userRepository.findAll.mockResolvedValue(mockList);

      const result = await userService.getAllUsers({
        name: "William",
      });

      expect(userRepository.findAll).toHaveBeenCalledWith({
        name: "William",
      });
      expect(result).toEqual(mockList);
    });
    
    test("lists users with email filter", async () => {
      const mockList = [{ id: 1, name: "William", email: "william@email.com" }];
      userRepository.findAll.mockResolvedValue(mockList);

      const result = await userService.getAllUsers({
        email: "william@email.com",
      });

      expect(userRepository.findAll).toHaveBeenCalledWith({
        email: "william@email.com",
      });
      expect(result).toEqual(mockList);
    });

    test("lists users without filters", async () => {
      userRepository.findAll.mockResolvedValue([]);
      await userService.getAllUsers({});
      expect(userRepository.findAll).toHaveBeenCalledWith({});
    });
  });
});
