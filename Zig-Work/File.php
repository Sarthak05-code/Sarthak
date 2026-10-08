<?php

class Validator
{
    public function __construct(public string $email)
    {
        // empty
    }

    public static function isEmail(): bool
    {
        return true;
    }

    public function value() : void
    {
        echo "The email is : {$this->email}";
    }
}

$v = new Validator("ytsarthak!@gmail.com");
Validator::isEmail();
$v->value();
