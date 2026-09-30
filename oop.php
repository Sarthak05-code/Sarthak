<?php

interface Permissions
{
    public function caller();
    public function auth();
}

class MiddleWare implements Permissions
{
    #[Override]
    public function caller()
    {
        echo "caller function called";
        return $this;
    }

    #[Override]
    public function auth()
    {
        echo "auth function called.";
        return $this;
    }
    public function isPassword(string $password, bool $hash = false)
    {
        if ($hash) {
            echo "Password => " . $password;
        } else {
            echo "Password => " . password_hash($password, PASSWORD_DEFAULT);
        }
        return $this;
    }

    public function isValid()
    {
        echo "Validation checker";
        return $this;
    }
}

class Person
{
    public function __construct(string $name)
    {
        echo "Hello " . $name;
    }

    public function info()
    {
        echo "Hello from function.";
    }
}

class Student extends Person
{
    #[Override]
    public function info()
    {
        echo "Hello, from student";
    }
}

class Teacher extends Person
{
    #[Override]
    public function info()
    {
        echo "Hello, from teacher";
    }
}

$p = new Person("Hello");
$p->info();
$s = new Student("Hello, student");
$s->info();
$t = new Teacher("Hello, teacher");
$t->info();

$middleware = new MiddleWare();
$middleware->auth()->isPassword(12345)->isValid();
$middleware->caller()->isValid()->caller()->isPassword(12345, true);
