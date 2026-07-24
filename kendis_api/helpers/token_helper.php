<?php
function generateToken(int $length = 64): string
{
    return bin2hex(random_bytes($length / 2));
}