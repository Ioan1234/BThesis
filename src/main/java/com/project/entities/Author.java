package com.project.entities;

public class Author {

    private String name;
    private String surname;

    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return this.name;
    }

    public void setSurname(String surname) {
        this.surname = surname;
    }

    public String getSurname() {
        return this.surname;
    }

    public String getFullName() {
        return this.name + " " + this.surname;
    }
}
