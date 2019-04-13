/************************************************************************
 PriorityQueue.cpp, enhanced and modified by Dan Bennett 01/26/2019

 Program to generate random priority/value numbers, save them to a file,
 retrieve them from a file into arrays, create a linked list and sort the
 priority/value numbers according to priority, and display a prioritized
 list of the values

 Reading values from a file simulate an embedded control system getting
 inputs that need to be prioritized
 The values represent tasks that an embedded control system would need to
 perform in an order according to the priority of the task
************************************************************************/

#include "pch.h"
#include <stdio.h> 
#include <stdlib.h> 
#include <iostream>
#include <fstream>
#include <time.h>

using namespace std;

// define the node type of structure 
typedef struct node
{
	int value;
    int priority;
	struct node* next;
} Node;

// create a new node from a priority/value pair 
Node* newNode(int v, int p)
{
	Node* temp = (Node*)malloc(sizeof(Node));
    temp->value = v;
    temp->priority = p;
    temp->next = NULL;

    return temp;
}

// get the head value 
int peek(Node** head)
{
    return (*head)->value;
}

// remove the head node from the queue 
void pop(Node** head)
{
     Node* temp = *head;
     (*head) = (*head)->next;
     free(temp);
}

// place nodes into queue according to priority 
void push(Node** head, int v, int p)
{
    Node* start = (*head); // create head of queue
    Node* temp = newNode(v, p); // create a new node

    if ((*head)->priority >= p) // insert new node at head if higher priority
	{
		temp->next = *head;
        (*head) = temp;
    }
    else {

        // otherwise find the correct position in queue to insert new node 
        while (start->next != NULL && start->next->priority < p)
		{
             start = start->next;
        }

        temp->next = start->next;
        start->next = temp;
    }
}

// check if queue is empty 
int isEmpty(Node** head)
{
    return (*head) == NULL;
}

int main()
{
	int priorityArray[10];
	int valueArray[10];

	// open write file, generate random munmbers for priority, write numbers to file
	ofstream pOutfile;
	pOutfile.open("priority.dat");
	srand(time(NULL));
	for (int i = 0; i < 10; i++)
		pOutfile << rand() % 100 << endl;
	pOutfile.close();

	// open write file, generate random munmbers for value, write numbers to file
	ofstream vOutfile;
	vOutfile.open("value.dat");
	for (int i = 0; i < 10; i++)
		vOutfile << rand() % 100 << endl;
	vOutfile.close();

	// open read file, read priority munmbers into array
	ifstream pInfile;
	pInfile.open("priority.dat");
	for (int i = 0; i < 10; i++)
		pInfile >> priorityArray[i];
	pInfile.close();

	// open read file, read value numbers into array
	ifstream vInfile;
	vInfile.open("value.dat");
	for (int i = 0; i < 10; i++)
		vInfile >> valueArray[i];
	vInfile.close();

    // create priority queue 
	Node* pq = newNode(valueArray[0], priorityArray[0]);
	for (int i = 1; i < 10; i++)
		push(&pq, valueArray[i], priorityArray[i]);

	// display priority numbers
	printf("P =\t ");
	for (int i = 0; i < 10; i++)
		printf("%d\t", priorityArray[i]);

	printf("\nV =\t ");
	
	// display value numbers
	for (int i = 0; i < 10; i++)
		printf("%d\t", valueArray[i]);

	printf("\nQ =\t ");

	// display prioritized values
	while (!isEmpty(&pq)) {
		printf("%d\t", peek(&pq));
        pop(&pq);
    }

	printf("\n\nP - the priority of the priority/value pair\n");
	printf("V - the value of the priority/value pair\n");
	printf("Q - the prioritized list of values in the queue\n");

    return 0;
}
